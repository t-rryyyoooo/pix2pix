import argparse
import cloudpickle

def parseArgs():
    parser = argsparse.ArgumentParser()

    parser.add_argument("data_path", help="~/Desktop/imaging.nii.gz")
    parser.add_argument("model_path", help="~/Desktop/latest.pkl")
    parser.add_argument("save_path", help="~/Desktop/translate.mha")

    args = parser.parse_args()

    return args

def main(args):


if __name__ == "__main__":
    args = parseArgs()
    main(args)


