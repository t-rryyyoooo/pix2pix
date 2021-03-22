import sys
sys.path.append("..")
import argparse
import cloudpickle
import SimpleITK as sitk
import cv2
from pathlib import Path
from utils.machineLearning.segmentation import Segmenter as Translater

def parseArgs():
    parser = argparse.ArgumentParser()

    parser.add_argument("image_dir", help="$HOME/case_00/imaging.nii.gz")
    parser.add_argument("model_path", help="$HOME/latest.pkl")
    parser.add_argument("save_dir", help=="$HOME/case_00/translate.mha")
    parser.add_argument("--gpu_ids", type=int, nargs="*", default=0)

def main(args):
    with open(args.model_path, "rb") as f:
        model = cloudpickle(f)
        model = torch.nn.DataParallel(model, device_ids=args.gpu_ids)

    model.eval()
    
    use_cuda = torch.cuda.is_available() and True
    device = torch.device("cuda" if use_cuda else "cpu")

    translater = Translater(
                    model,
                    num_input_array = 1,
                    ndim            = 4,
                    device          = device
                    )

    image_dir  = Path(args.image_dir)
    image_iter = sorted(image_dir.glob("input*"))

    save_dir = Path(args.save_dir)
    for image_path in image_iter:
        print("image_path: ", str(image_path))

        image_array = np.load(str(image_path))

        translated_image = translater.forward(image_array)

        save_name_npy = (image_name.name).replace("input", "translate")
        save_name_jpg = save_name_npy.replace("npy", "jpg")

        save_path_npy = save_dir / save_name_npy
        save_path_jpg = save_dir / save_name_jpg

        print("save_path: ", str(save_path))
        #np.save(str(save_path_npy), translated_image)
        cv2.imwrite(str(save_path_jpg), translated_image)
        
if __name__ == "__main__":
    args = parseArgs()
    main(args)
