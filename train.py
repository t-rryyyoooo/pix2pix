import argparse
import sys
import pytorch_lightning as pl
sys.path.append("..")
from model.pix2pix.system import Pix2PixSystem
from utils.utils import setSeed
from pytorch_lightning.loggers import TensorBoardLogger

def parseArgs():
    parser = argparse.ArgumentParser()

    parser.add_argument("dataset_path")
    parser.add_argument("log_path")
    parser.add_argument("--train_list", help="00 01", nargs="*", default= "00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19")
    parser.add_argument("--val_list", help="20 21", nargs="*", default="20 21 22 23 24 25 26 27 28 29")
    parser.add_argument("--test_list", help="20 21", nargs="*", default="20 21 22 23 24 25 26 27 28 29")
    parser.add_argument("--num_columns", default=5)
    parser.add_argument("--lr", default=0.001, type=float)
    parser.add_argument("--l1_lambda", default=100., type=float)
    parser.add_argument("--batch_size", default=3, type=int)
    parser.add_argument("--num_workers", default=6, type=int)
    parser.add_argument("--G_input_ch", default=1, type=int)
    parser.add_argument("--G_output_ch", default=1, type=int)
    parser.add_argument("--G_name", default="unet_256")
    parser.add_argument("--D_input_ch", default=2, type=int)
    parser.add_argument("--D_name", default="PatchGAN")
    parser.add_argument("--D_n_layers", default=3, type=int)
    parser.add_argument("--ngf", default=64, type=int, help="Refer the discriminator.py or generator.py and so on.")
    parser.add_argument("--epoch", default=100, type=int)
    parser.add_argument("--gpu_ids", default=[0], type=int, nargs="*")

    args = parser.parse_args()

    return args

def main(args):
    setSeed()
    criteria = {
            "train" : args.train_list,
            "val"   : args.val_list,
            "test"  : args.test_list
            }

    system = Pix2PixSystem(
                dataset_path = args.dataset_path,
                criteria     = criteria,
                log_path     = args.log_path,
                lr           = args.lr,
                l1_lambda    = args.l1_lambda,
                batch_size   = args.batch_size,
                num_workers  = args.num_workers,
                G_input_ch   = args.G_input_ch,
                G_output_ch  = args.G_output_ch,
                G_name       = args.G_name,
                D_input_ch   = args.D_input_ch,
                D_name       = args.D_name,
                D_n_layers   = args.D_n_layers,
                ngf          = args.ngf,
                gpu_ids      = args.gpu_ids
                )

    logger = TensorBoardLogger(args.log_path)
            
    trainer = pl.Trainer(
                num_sanity_val_steps = 0,
                max_epochs           = args.epoch,
                checkpoint_callback  = None,
                logger               = logger,
                gpus                 = args.gpu_ids,
                #reload_dataloaders_every_epoch = True
                )

    trainer.fit(system)

if __name__ == "__main__":
    args = parseArgs()
    main(args)





