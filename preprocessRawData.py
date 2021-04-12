import argparse

def parseArgs():
    parser = argparse.ArgumentParser()

    parser.add_argument("data_dir", help="data/Abdomen")
    parser.add_argument("save_dir", help="data/Abdomen")
    parser.add_argument("--org_direction", help="data/Abdomen")
    parser.add_argument("--spacing", help="0.78 0.78 3.0")
    parser.add_argument("--origin", help="0.0 0.0 0.0")
    parser.add_argument("--direction", help="1.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 1.0")

