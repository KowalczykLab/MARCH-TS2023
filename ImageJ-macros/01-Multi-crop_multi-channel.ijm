/*
 * 2022-01-30 William Giang
 * Two channel cropping for EzColocalization 
 * 
 * Assumes you have already: 
 * 		 - Created ROIs and saved them with a similar name to your image files
 * 		 
 *  Note: You may need to run "Fix Funny Filenames" if your images have spaces
 */

#@ File (label = "Input image directory", style = "directory") input
#@ File (label = "Input ROI directory", style = "directory") input_ROI_dir
#@ File (label = "Output directory", style = "directory") output
#@ String (choices={"C1", "C2", "C3", "C4"}, style="listBox") C1
#@ String (choices={"C1", "C2", "C3", "C4"}, style="listBox") C2
#@ String (choices={"C1", "C2", "C3", "C4"}, style="listBox") C3
#@ String (label = "Input image suffix", value = ".tif") suffix



File.makeDirectory(output + File.separator + C1);
File.makeDirectory(output + File.separator + C2);
File.makeDirectory(output + File.separator + C3);

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	
	}
	print("Done");
}

function processFile(input, output, file) {
	// Fresh start by clearing Results table and ROI manager
	run("Fresh Start");
		
	// Let the user see what's happening
	print("Processing: " + input + File.separator + file);
	open(input + File.separator + file);
	
	title_orig = getTitle();
	
	// Assumes ROIs naming convention
	ROI_set = File.nameWithoutExtension + "-RoiSet.roi.zip";
	
	// Load ROIs
	roiManager("Open", input_ROI_dir + File.separator + ROI_set);
	roiManager("Remove Channel Info");
	//roiManager("Remove Slice Info");
	//roiManager("Remove Frame Info");
	
	run("Split Channels");

	C1_dash = C1 + "-";
	C2_dash = C2 + "-";
	C3_dash = C3 + "-";
	
	C1_name = C1_dash + title_orig;
	C2_name = C2_dash + title_orig;
	C3_name = C3_dash + title_orig;
	
	C1_name_no_ext = C1_dash + File.nameWithoutExtension;
	C2_name_no_ext = C2_dash + File.nameWithoutExtension;
	C3_name_no_ext = C3_dash + File.nameWithoutExtension;
	
	selectWindow(C1_name);
	RoiManager.multiCrop(output + File.separator + C1 + File.separator + C1_name_no_ext + "_", " save tif");
	selectWindow(C2_name);
	RoiManager.multiCrop(output + File.separator + C2 + File.separator + C2_name_no_ext + "_", " save tif");
	selectWindow(C3_name);
	RoiManager.multiCrop(output + File.separator + C3 + File.separator + C3_name_no_ext + "_", " save tif");

	run("Close All");
	/*
	// EzColoc for Channel 2 vs. Channel 3
	run("EzColocalization ", "reporter_1_(ch.1)=" + C2 + 
		" reporter_2_(ch.2)=" + C3 + 
		" cell_identification_input=[ROI Manager] " + 		   // cell selection from ROI-manager
		"alignthold4=percentile "+ 							   // no additional alignment of channels
		"area=5-Infinity " + 								   // exclude small particles
		"srcc metricthold3=all allft-c1-3=10 allft-c2-3=10 " +  // SRCC all
		"roi(s)");         									   //  cell ID using ROIs

	//selectWindow("Metric(s) of ROI Manager");
	//saveAs("Results", output + File.separator + File.nameWithoutExtension + "_EzC.csv");
	//close();
	//close("EzColocalization");
	close("*");

	*/
}
