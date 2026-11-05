# synthetic_watershed
 
The popular Watershed segmentation algorithm, although very popular, suffers from over-segmentation. This means that it can partition a feature into sub-parts (fragmentation). This is due to excessive local minima in the Euclidean Distance Transform (EDT), a necessary step. Traditionally these additional minima are cleaned up by gaussian filtering. However, knowing the root cause of oversegmentation can help users of Watershed choose the right filtering methods for their applications.

This repo has tools to analyze the root cause of generation of these excessive minima. They occur due to 'corner pixels', which are pixels at the border of feature in binarized images. 

Details - In order to apply the watershed algorithm on an image, the following steps are done:
1. Binarization - The image is binarized into a dark background and a bright foreground. The bright parts are the features which must be segmented
2. Euclidean Distance Transform is taken, which converts the binarized image into a pixel map.
3. Watershed is run on the EDT image.

The EDT contains several local monima, which serve as seeds for watershed. Each local minimum leads to a separately segmented region. The root cause is as follows:
1. Consider a boundary of a binarized feature. It has 'white' pixels inside the feature and 'black' pixels along the boundary.
2. Define a 'corner pixel' as a dark pixel on the feature boundary, which has a at least two bright pixels as part of its 4 neighbours (left, right, up, down).
3. During EDT computation, the distance of each bright pixel is from the boundary is computed. The distance to the nearest dark pixel becomes the EDT value assigned to a given bright pixel.
4. Start from bright pixels closest to a boundary. The closest dark pixels are easily seen to be either normal or corner dark pixels nearby. As we move into the feature interior, the closest dark pixel suddenly switches over to some other dark pixel. At the point of this crossover, local minima usually appear.
5. An analytic EDT does not have this, but a pixelated EDT almost always does.
6. An example is an ellipse. An axis-aligned ellipse hardly has any local minima. But if the ellipse is rotated, a large number of local minima appear along the medial axis.
