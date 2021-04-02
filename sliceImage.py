import argparse
import SimpleITK as sitk
import numpy as np
import sys
sys.path.append("..")
from utils.utils import getSizeFromString
from imageSlicer import ImageSlicer

def parseArgs():
    parser = argparse.ArgumentParser()

    parser.add_argument("input_image_path", help="case_00/imaging_1.nii.gz")
    parser.add_argument("target_image_path", help="case_00/imaging_2.nii.gz")
    parser.add_argument("save_dir", help="patch/case_00")
    parser.add_argument("patient_id", help="00")
    parser.add_argument("--mask_image_path", help="case_00/mask.nii.gz")
    parser.add_argument("--input_patch_size", help="256-256")
    parser.add_argument("--target_patch_size", help="256-256")
    parser.add_argument("--slide", help="256-256")
    parser.add_argument("--axis", type=int, help="Image arrayis sliced perpendicular to it. [ex] 0", default=0)
    parser.add_argument("--input_name", help="Saved input patch name.", default="input")
    parser.add_argument("--target_name", help="Saved target patch name.", default="target")
    parser.add_argument("--with_nonmask", action="store_true")

    args = parser.parse_args()

    return args

def main(args):
    input_image  = sitk.ReadImage(args.input_image_path)
    target_image = sitk.ReadImage(args.target_image_path)

    if args.mask_image_path is None:
        mask_image = None
    else:
        mask_image = sitk.ReadImage(args.mask_image_path)

    if args.input_patch_size is None:
        input_patch_size = None
    else:
        input_patch_size = getSizeFromString(args.input_patch_size, digit=2)
    if args.target_patch_size is None:
        target_patch_size = None
    else:
        target_patch_size = getSizeFromString(args.target_patch_size, digit=2)

    if args.slide is None:
        slide = None
    else:
        slide = getSizeFromString(args.slide, digit=2)

    image_slicer = ImageSlicer(
                    input_image,
                    target_image,
                    input_patch_size  = input_patch_size,
                    target_patch_size = target_patch_size,
                    slide             = slide,
                    axis              = args.axis,
                    mask_image        = mask_image
                    )

    image_slicer.savePatchArray(
                    args.save_dir, 
                    args.patient_id, 
                    input_name   = args.input_name, 
                    target_name  = args.target_name,
                    with_nonmask = args.with_nonmask
                    )

if __name__ == "__main__":
    args = parseArgs()
    main(args)

