what does my script do? 

1) quantize all the frames.
	quantize reduces the number of colors while trying to perserve the quality of the image.
	
2) resize all of the frames to the specified sizes by the user. 

3) for each frame:
	3.1) convert to RGB values.
	3.2) gamma correct each RGB value of the frame.
	
4) now that we have all the frames converted and gamma corrected:
	4.1) compress the frames!
	
how does the compression work?
	1) we go over the frames from the end to the beginning and we delete all the identical colors
		of the current frame and the previous frame, from the current frame.
	2) we go over all the new frames and replace every interval that has the same colors as neighbours, with [color,start_index,length], such as color is the index of color in the colors list, start_index
		is the start index of the interval and length is the number of neighbours with identical colors in the interval.
		2.1) all the colors that are used in the gif will be in a list called color pallete, in RGB format. and we will map the colors of the gif to this list.
		
	