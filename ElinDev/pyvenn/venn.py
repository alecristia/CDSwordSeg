#!/usr/bin/python
"""PyVenn

Venn Diagrams for python,
both proportional and 'normal'.

Currently draws 2 set diagrams by itself,
passes larger diagrams (normal) on to the R library 'vennerable'
using rpy2 (and numpy). 
Should work without rpy2 installed.
Work in progress.

Usage:
    vd = VennDiagram ( [ ("One set", [1,2,3]), ("Other Set", [3, 4, 5, 6])])
    vd.plot_normal('test_normal.png')
    vd.plot_proportional('test_proportional.png')

Requires:
    numpy
    cairo

Option:
    rpy2 ( and the Vennerable R library)

Released under:
The MIT License

Copyright (c) 2010, Florian Finkernagel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


"""

import cairo
import math
import numpy
import unittest
_r_loaded = False
robjects = None
def load_r():
    global _r_loaded
    global robjects
    import rpy2.robjects
    import rpy2.robjects.numpy2ri #so the numpy->r interface works
    try:
        rpy2.robjects.numpy2ri.activate()
    except AttributeError:
        pass
    robjects = rpy2.robjects
    if not _r_loaded:
        robjects.r('library(Vennerable)')

class VennDiagram:

    def __init__(self, name_set_tuples_or_dict):
        if hasattr(name_set_tuples_or_dict, 'items'):
            sets = name_set_tuples_or_dict.items()
        else:
            sets = name_set_tuples_or_dict
        self.sets = []
        for name, group in sets:
            self.sets.append((name, set(group)))

    default_colors = [ (228 / 255.0, 26 / 255.0, 28 / 255.0), 
                              (55 / 255.0, 126 / 255.0, 184 / 255.0), 
                              (77 / 255.0, 175 / 255.0, 74 / 255.0)]


    def plot_normal(self, output_filename, width=8, colors=None):
        if len(self.sets) == 2:
            self._plot_proportional_two(output_filename, width, colors, weight_func = lambda a,b,c: (1,1,1)) #special case, same weight for all sections.
        else:
            self._venn_plot_weights(output_filename, width, width)

    def plot_proportional(self, output_filename, width=8,  
                          colors=None):
        if len(self.sets) == 2:
            self._plot_proportional_two(output_filename, width, colors, weight_func=(lambda a, b,c: (a, b, c)))
        elif len(self.sets) == 3:
            self._plot_proportional_three(output_filename, width)
        else:
            raise ValueError("Can currently only plot 2 or 3 set venn diagrams in a proportional method")
     
    def _get_set_names(self):
        return [x[0] for x in self.sets]

    def _get_set_values(self):
        return [x[1] for x in self.sets]

    def _venn_plot_sets(self, output_filename, width=8, height=8):
        """Plot a venn diagram into the pdf file output_filename.
        Takes a dictionary of sets and passes them straight on to R"""
        raise TypeError("This function should no longer be used. use _venn_plot_weigths instead")
        sets = self.sets
        load_r()
        robjects.r('pdf')(output_filename, width=width, height=height)
        x = robjects.r('Venn')(Sets = [numpy.array(list(x)) for x in self._get_set_values()], SetNames=[x for x in self._get_set_names()])
        robjects.r('plot')(x, **{'type': 'squares', 'doWeights': False})
        robjects.r('dev.off()')

    def _venn_plot_weights(self, output_filename, width=8, height=8):
        """Plot a venn diagram into the pdf file output_filename.
        Takes a dictionary of sets and does the intersection calculation in python
        (which hopefully is a lot faster than passing 10k set elements to R)
        """
        load_r()
        weights = [0]
        sets_by_power_of_two = {}
        for ii, kset in enumerate(self._get_set_names()):
            iset = self._get_set_values()[ii]
            sets_by_power_of_two[2**ii] = set(iset)
        for i in xrange(1, 2**len(self.sets)):
            sets_to_intersect = []
            to_exclude = set()
            for ii in xrange(0, len(self.sets)):
                if (i & (2**ii)):
                    sets_to_intersect.append(sets_by_power_of_two[i & (2**ii)])
                else:
                    to_exclude = to_exclude.union(sets_by_power_of_two[(2**ii)])
            final = set.intersection(*sets_to_intersect) - to_exclude
            weights.append( len(final))
        robjects.r('pdf')(output_filename, width=width, height=height)
        x = robjects.r('Venn')(Weight = numpy.array(weights), SetNames=self._get_set_names())
        if len(self.sets) <= 3:
            venn_type = 'circles'
        else:
            venn_type = 'squares'

        robjects.r('plot')(x, **{'type': venn_type, 'doWeights': False})
        robjects.r('dev.off()')

    def _centered_text(self, ctx, x, y, text):
        extends = ctx.text_extents(text)
        ctx.move_to(x -  extends[4] / 2.0,
                    y + 1 * extends[5] / 2.0)
        ctx.show_text(text)

    def _calculate_overlap(self, r1, r2, d):
        """Calculate the overlap of two spheres at 0,0 (radius=r1) and d, 0 (radius=r2)"""
        alpha = ((d**2 + r1**2 - r2**2) / (2 * r1 * d))
        alpha = 2 * math.acos(alpha)
        beta = ((d**2 + r2**2 - r1**2) / (2 * r2 * d))
        beta = 2 * math.acos(beta)
        return (0.5 * r1**2 * (alpha - math.sin(alpha)) +
                0.5 * r2**2 * (beta - math.sin(beta)))

    def _plot_proportional_two(self, output_filename, width, colors, weight_func):
        """Plot a two set venn diagram.

        Width is in inches, height is automatically choosen.
        
        """
        
        if colors is None:
            colors = self.default_colors
        sets = self._get_set_values()
        count_A_and_B = len(sets[0].intersection(sets[1]))
        count_A_and_not_B = len(sets[0]) - count_A_and_B
        count_not_A_and_B = len(sets[1]) - count_A_and_B
        weight_A_and_B, weight_A_and_not_B, weight_not_A_and_B = weight_func(count_A_and_B, count_A_and_not_B, count_not_A_and_B)

        def calculate_spheres(weight_A_and_B, weight_A_and_not_B, weight_not_A_and_B):
            """Calculate the radii and second sphere position for two spheres that overlap
            as specificed by the weights. 

            Calculation ala Chow & Ruskey, "Drawing Area-Proportianl Venn and Euler Diagrams"
            
            returns r1, r2, distance_between_spheres
            First sphere is at 0,0, second at 0, distance_between_spheres.

            """
            r1 = math.sqrt((weight_A_and_not_B + weight_A_and_B) / math.pi)
            r2 = math.sqrt((weight_not_A_and_B + weight_A_and_B) / math.pi)

            min_d = abs(r1 - r2) #fully overlapping
            max_d = r1 + r2 # no overlap.
            upper = max_d
            lower = min_d
            allowed_difference = weight_A_and_B / 100.0
            while lower != upper:
                test_d = (lower + upper) / 2.0
                overlap = self._calculate_overlap(r1, r2, test_d)
                if abs(overlap - weight_A_and_B) <= allowed_difference:
                    break
                else:
                    if overlap > weight_A_and_B: #overlap is too large
                        lower = test_d
                    else:
                        upper = test_d
                overlap = self._calculate_overlap(r1, r2, test_d)
            final_distance = test_d
            return r1, r2, final_distance
        
        def plot_spheres(radius1, radius2, distance_between_spheres):
            dpi = 72# might make problems with pdf if changed
            coordinate_width = (radius1 + distance_between_spheres + radius2) #how much room do we need for our sphere
            coordinate_height = 2 * max(radius1, radius2)
            image_width = int(math.ceil(dpi * width)) #this is the number of 'pixels' in the final image
            image_height = int(math.ceil(image_width * coordinate_height / float(coordinate_width)))
            if output_filename.endswith('.pdf'):
                surface = cairo.PDFSurface(output_filename, image_width, image_height) 
            elif output_filename.endswith('.png'):
                surface = cairo.ImageSurface(cairo.FORMAT_ARGB32,image_width, image_height)
            else:
                raise ValueError("_plot_proportional_two currently only understands .pdf and .png output filenames")
            ctx = cairo.Context(surface)
            ctx.scale(image_width / coordinate_width * 0.9, #give us some border that we'll use for the text's at the end
                     image_height / coordinate_height * 0.9)
           
            ctx.translate(
                radius1 * 1.1,
                coordinate_height / 2.0 * 1.1
            )
            ctx.set_line_width(coordinate_width / 300.0)

            #first we fill both with their respective color
            ctx.arc(0,0, radius1 / 1.0, 0, 2 * math.pi)
            ctx.set_source_rgba(colors[0][0], colors[0][1],colors[0][2],0.8)
            ctx.fill()

            ctx.arc(distance_between_spheres,0, radius2 / 1.0, 0, 2 * math.pi)
            ctx.set_source_rgba(colors[1][0], colors[1][1],colors[1][2],0.8)
            ctx.fill()

            #then we stroke them with black
            ctx.set_source_rgba(0,0,0,0.5)
            ctx.arc(distance_between_spheres,0, radius2 / 1.0, 0, 2 * math.pi)
            ctx.stroke()
            ctx.arc(0,0, radius1 / 1.0, 0, 2 * math.pi)
            ctx.stroke()

            #then we add numbers
            ctx.set_source_rgba(0,0,0,1)
            font_size = coordinate_height / 30.0
            ctx.set_font_size(font_size)
            ctx.select_font_face('sans-serif', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)

            only_a = 0 #Centered in the circle
            if only_a + ctx.text_extents(str(count_A_and_not_B))[4] / 2.0 >= distance_between_spheres - radius2: #ie, the text would overlap with with the next circle
                only_a = (-radius1 + min(distance_between_spheres - radius2, radius1)) / 2.0
            self._centered_text(ctx, only_a,0,str(count_A_and_not_B))
            only_b = distance_between_spheres
            if only_b - (ctx.text_extents(str(count_not_A_and_B))[4] / 2.0) <= radius1:#the number overlaps with the previous circle / the overlap zone 
                only_b = ((distance_between_spheres + radius2) 
                    + max(radius1, (distance_between_spheres - radius2)) ) / 2.0
            self._centered_text(ctx, only_b,0,str(count_not_A_and_B))
            if (count_A_and_B):#no number if overlap is 0
                self._centered_text(ctx,
                    (radius1 + distance_between_spheres - radius2) / 2.0 ,0,str(count_A_and_B))

            ctx.set_source_rgba(colors[0][0], colors[0][1],colors[0][2],0.8)
            self._centered_text(ctx, 0, - coordinate_height / 2.0 - font_size / 2.0, 
                          self._get_set_names()[0])
            ctx.set_source_rgba(colors[1][0], colors[1][1],colors[1][2],0.8)
            self._centered_text(ctx, distance_between_spheres, + coordinate_height / 2.0 + font_size , self._get_set_names()[1])

            if output_filename.endswith('.pdf'):
                pass #taken care of when initializing the surface
            else:
                surface.write_to_png(output_filename)
            surface.finish()

        radius1, radius2, distance_between_spheres = calculate_spheres(weight_A_and_B, weight_A_and_not_B, weight_not_A_and_B)
        plot_spheres(radius1, radius2, distance_between_spheres)


    def _plot_proportional_three(self, output_filename, width):
        raise NotImplementedError()



class TestVennDiagram(unittest.TestCase):
    """These 'unit tests' don't deserve their name - but at least the 
    ascertain that we don't throw an exception."""
    def test_normal(self):
        of = "test.png"
        sets = {
            'A': [1,2,3,44],
            'B': [2,3,55,66,77]
        }
        d = VennDiagram(sets)
        d.plot_normal(of)

    def test_proportional(self):
        of = "test_prob.png"
        sets = [
            ('and the very blue', range(20000,22000) + range(555,6660)),
            ('The very red', range(0000,2000) + range(555,6660)),
        ]
        d = VennDiagram(sets)
        d.plot_proportional(of, width=10)

    def test_proportional3(self):
        of = "test_prob3.png"
        sets = [
            ('and the very blue', range(20000,22000) + range(555,6660)),
            ('The very red', range(0000,2000) + range(555,6660)),
            ('and the other kind', range(0,1500) + range(20000,200010)),
        ]
        d = VennDiagram(sets)
        d.plot_proportional(of, width=10)

    def test_proportional_more_than_3_raises(self):
        def inner():
            sets = [
                ('and the very blue', range(20000,22000) + range(555,6660)),
                ('The very red', range(0000,2000) + range(555,6660)),
                ('and the other kind', range(0,1500) + range(20000,200010)),
                ('there is no fourth set', [])
            ]
            d = VennDiagram(sets)
            d.plot_proportional('idontexist.png', width=10)
        self.assertRaises(ValueError,inner)


    def test_proportional_pdf(self):
        of = "test_prob.pdf"
        sets = [
            ('and the very blue', range(20000,22000) + range(555,6660)),
            ('The very red', range(0000,2000) + range(555,6660)),
        ]
        d = VennDiagram(sets)
        d.plot_proportional(of, width=10)

if __name__ == '__main__': 
    import sys
    from optparse import OptionParser
    def printUsage():
        print "venn.py -f output.png (--width 8) count_A_and_B count_A_not_B count_notA_And_B set_name_a, set_name_b"
        sys.exit(1)
    parser = OptionParser()
    parser.add_option('-t', '--test', dest="is_test", action="store_true", help="Run unittests (and create a bunch of test*.png/pdf")
    parser.add_option('-f', '--output_filename', dest='output_filename', help="output filename, must end with .png or .pdf")
    parser.add_option('-w', '--width', dest='width', help="output image width in inch (resolution: 72 dpi")
    (options, args) = parser.parse_args()
    if options.is_test is True:
        unittest.main()
    if options.width is None:
        width = 8
    else:
        width = int(options.width)
    if options.output_filename is None:
        printUsage()
    if len(args) != 5:
        print 'Error: Not enough arguments'
        printUsage()
    in_A_and_B = int(args[0])
    in_A_and_not_B = int(args[1])
    in_not_A_and_B = int(args[2])
    set_A = range(0, in_A_and_B + in_A_and_not_B)
    set_B = range(in_A_and_not_B, in_A_and_not_B + in_A_and_B + in_not_A_and_B)
    set_name_a = args[3]
    set_name_b = args[4]
    vd = VennDiagram([
        (set_name_a, set_A),
        (set_name_b, set_B),
    ])
    vd.plot_proportional(options.output_filename, width)
    sys.exit(0)
