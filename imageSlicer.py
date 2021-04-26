import numpy as np
import SimpleITK as sitk
import sys
sys.path.append("..")
from utils.imagProcessing.cropping import croppingForNumpy
from utils.imagProcessing.padding import paddingForNumpy
from utils.patchGenerator.slicePatchGenerator import SlicePatchGenerator

def ImageSlicer():
    def __init__(self, image=None, target=None, image_patch_width=1, target_patch_width=1, plane_size=None, overlap=1, axis=0, mask=None):
        """ Pad or crop images to plane size and slice them perpendicular to axis.

        Parameters: 
        image (sitk.Image)       -- 3D image.
        target (sitk.Image)      -- 3D image. Target size equals to image size.
        image_patch_width (int)  -- Patch width along axis. When axis=0, patch size is [image_patch_width, plane_size]
        target_patch_width (int) -- Patch width along axis.
        plane_size (list)        -- The plane size perpendicular to axis.
        overlap (int)
        mask (sitk.Image)
        """

        self.org = image

        self.image_array  = sitk.GetArrayFromImage(image)
        self.target_array = sitk.GetArrayFromImage(target)

        self.image_patch_width  = image_patch_width
        self.target_patch_width = target_patch_width

        if plane_size is None:
            self.plane_size = getPlaneSize(self.image_array.shape, axis)
        else:
            self.plane_size = plane_size

        self.slide = target_patch_width // overlap
        self.axsi  = axis

        if mask is None:
            self.mask_array = np.ones_like(self.image_array)
        else:
            self.mask_array = sitk.GetArrayFromImage(mask)

        self.setGenerator()

    def setGenerator(self):
        self.image_array  = self.adjustArraySizeInPlane(self.image_array, self.plane_size, self.axis)
        self.target_array = self.adjustArraySize(self., self.plane_size, self.axis)
        self.mask_array   = self.adjustArraySize(self.mask_array, self.plane_size, self.axis)

        self.lower_pad_size, self.upper_pad_size = calculatePaddingSize(
                                                    self.input_image_array.shape,
                                                    np.insert(self.plane_size, self.axis, self.image_patch_width),
                                                    np.insert(self.plane_size, self.axis, self.target_patch_width),
                                                    np.insert(self.plane_size, self.axis, self.slide)
                                                    )

        """ Pad image and target array along axis. """
        self.image_array  = paddingForNumpy(
                                self.image_array,
                                self.lower_pad_size[0].tolist(),
                                self.upper_pad_size[0].tolist(),
                                )
        self.target_array = paddingForNumpy(
                                self.target_array,
                                self.lower_pad_size[1].tolist(),
                                self.upper_pad_size[1].tolist(),
                                )
        self.mask_array   = paddingForNumpy(
                                self.mask_array,
                                self.lower_pad_size[1].tolist(),
                                self.upper_pad_size[1].tolist()
                                )

        self.image_generator  = SlicePatchGenerator(
                                    image_array = self.image_array,
                                    patch_width = self.image_patch_width,
                                    slide       = self.slide,
                                    axis        = self.axis
                                    )
        self.target_generator = SlicePatchGenerator(
                                    image_array = self.target_array,
                                    patch_width = self.target_patch_width,
                                    slide       = self.slide,
                                    axis        = self.axis
                                    )
        self.mask_generator   = SlicePatchGenerator(
                                    image_array = self.mask_array,
                                    patch_width = self.target_patch_width,
                                    slide       = self.slide,
                                    axis        = self.axis
                                    )



    def adjustArraySizeInPlane(self, image_array, plane_size, axis):
        """ Pad or crop image array to required_shape perpendicular to axis.
        Parameters: 
            image_array(np.ndarray)
            required_shape (list)   
            axis (int) 

        Returns: 
            Adjusted array, diff (The differece between image size and required shape)
        """
        image_size     = np.array(image_array.shape)
        required_shape = np.insert(plane_size, axis, image_size[axis])
        print(required_shape)
        
        diff = required_shape - image_size
        lower_size = (abs(diff) // 2).tolist()
        upper_size = ((abs(diff) + 1) // 2).tolist()

        if (diff < 0).any():
            adjusted_array = croppingForNumpy(image_array, lower_size, upper_size)
        else:
            adjusted_array = paddingForNumpy(image_array, lower_size, upper_size)

        return adjusted_array, diff

    def getPlaneSize(self, image_size, axis):
        """ Output the plane size perpendicular to axis.

        Parameters:
            image_size (list or np.array) -- image array size
            axis (int)

        Returns:
            Plane size perpendicular to axis.
        """

        s = np.arange(len(image_size))
        s = np.delete(s, axis)
        plane_size = np.array(image_size)[s]

        return plane_size

    def generatePatchArray(self):
        "Generator which outputs input, target and mask patch array. """
        for ipa, tpa, mpa in zip(self.input_generator(), self.target_generator(), self.mask_generator()):
            slices = tpa[0]

            yield ipa[1], tpa[1], mpa[1], slices


