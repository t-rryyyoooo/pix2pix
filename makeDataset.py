import cv2
import numpy as np
import argparse
from pathlib import Path

def parseArgs():
    parser = argparse.ArgumentParser()

    parser.add_argument("data_dir")
    parser.add_argument("save_dir")

    args = parser.parse_args()

    return args

def splitImages(image_array):
    left_image, right_image = np.split(image_array, 2, axis=1)

    return left_image, right_image

def main(args):
    data_dir  = Path(args.data_dir)
    data_iter = data_dir.glob("*")
    data_iter = sorted(data_iter)

    save_dir = Path(args.save_dir)
    for i, data in enumerate(data_iter):
        image_array = cv2.imread(str(data))
        left_array, right_array = splitImages(image_array)

        #left_path = save_dir / "input_{}.npy".format(str(i).zfill(3))
        #right_path = save_dir / "target_{}.npy".format(str(i).zfill(3))

        #np.save(str(left_path), left_array)
        #np.save(str(right_path), right_array)
    
        left_path = save_dir / "input_{}.png".format(str(i).zfill(3))
        right_path = save_dir / "target_{}.png".format(str(i).zfill(3))

        cv2.imwrite(str(left_path), left_array)
        cv2.imwrite(str(right_path), right_array)

        print("{} done.".format(str(data)))


if __name__ == "__main__":
    args = parseArgs()
    main(args)
