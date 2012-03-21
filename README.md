MKV audio repacker
------------

CLI script to repack external audio-track into mkv container for every video files in directory.

I write it for myself, to have more comfort with some anime.

By default script create new directory, "*repacked*", you can change name with options *-o*

### How to use ###

	Usage: audio_repacker.rb [OPTIONS] AUDIO_DIR

	Specific options:
	    -v, --video [VIDEO_DIR]          Select directory where
	                                      video files will be coded
	    -o, --output [OUTPUT_DIR]        Select output directory

	Common options:
	    -h, --help                       Show this message
	        --version                    Show version

### Example ###

	audio_repacker.rb ./sound_dir/

### Limitation ##

You **MUST** have some number of video and audiofiles, or script return error.