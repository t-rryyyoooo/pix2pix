import sys
sys.path.append("..")
import argparse
import numpy as np
import torch
import cloudpickle
from tqdm import tqdm
import SimpleITK as sitk
from pathlib import Path
from utils.machineLearning.predict import Predictor as Translater
from imageSlicer import ImageSlicer
from utils.utils import getSizeFromStringElseNone, isMasked
from model.pix2pix.transform import Pix2PixTransform

def parseArgs():
    parser = argparse.ArgumentParser()

    parser.add_argument("image_path", help="$HOME/case_00/imaging.nii.gz")
    parser.add_argument("model_path", help="$HOME/latest.pkl")
    parser.add_argument("save_path", help="$HOME/case_00/translate.mha")
    parser.add_argument("--mask_path") 
    parser.add_argument("--input_patch_width", default=1, type=int)
    parser.add_argument("--target_patch_width", default=1, type=int)
    parser.add_argument("--plane_size")
    parser.add_argument("--overlap", type=int, default=1)
    parser.add_argument("--axis", default=0, type=int)
    parser.add_argument("--min_value", default=-300., type=float)
    parser.add_argument("--max_value", default=300, type=float)
    parser.add_argument("--gpu_ids", type=int, nargs="*", default=[0])
    
    args = parser.parse_args()

    return args

def main(args):
    image = sitk.ReadImage(args.image_path)
    dummy = sitk.Image(image.GetSize(), sitk.sitkInt8)
    dummy.SetOrigin(image.GetOrigin())
    dummy.SetDirection(image.GetDirection())
    dummy.SetSpacing(image.GetSpacing())

    if args.mask_path is not None:
        mask = sitk.ReadImage(args.mask_path)
    else:
        mask = None

    plane_size = getSizeFromStringElseNone(args.plane_size, digit=2)

    image_slicer = ImageSlicer(
                    image              = image,
                    target             = dummy,
                    image_patch_width  = args.input_patch_width,
                    target_patch_width = args.target_patch_width,
                    plane_size         = plane_size,
                    overlap            = args.overlap,
                    axis               = args.axis,
                    mask               = mask
                    )
 

    with open(args.model_path, "rb") as f:
        model = cloudpickle.load(f)
        model = torch.nn.DataParallel(model, device_ids=args.gpu_ids)

    model.eval()
    
    use_cuda = torch.cuda.is_available() and True
    device = torch.device("cuda" if use_cuda else "cpu")

    transform = Pix2PixTransform()

    translater = Translater(
                    model,
                    device = device
                    )

    with tqdm(total=image_slicer.__len__(), ncols=60, desc="Segmenting and Restoring...") as pbar:
        for image_patch_array, dummy_patch_array, mask_patch_array, index in image_slicer.generatePatchArray():
            if isMasked(mask_patch_array):
                image_patch_array, _ = transform("test", image_patch_array, dummy_patch_array)

                translated_array = translater(image_patch_array).clip(min=0., max=1.)
                translated_array = translated_array * (args.max_value - args.min_value) + args.min_value



                image_slicer.insertToPredictedArray(index, translated_array)


            pbar.update(1)

    translated = image_slicer.outputRestoredImage()

    save_path = Path(args.save_path)
    save_path.parent.mkdir(parents=True, exist_ok=True)

    print("Saving predicted image to {}".format(str(save_path)))
    sitk.WriteImage(translated, str(save_path), True)

if __name__ == "__main__":
    args = parseArgs()
    main(args)
