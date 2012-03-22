MKV audio repacker
------------

CLI script to repack external audio-track into mkv container for every video files in directory.

I write it for myself, to have more comfort with some anime.

By default script create new directory, "*repacked*", you can change name with options *-o*

By default script wipe out all audio tracks from source container, you can keep it with *--keep_audio* 

### Reason to exist ###

I need fast solution to batch repack mkv with external audio track when CLI **DONT CARE** about filenames at all.

In other words, you **MAY** repack containers named '01-my-cool-anime.mkv' and '02-my-another-cool-anime.mkv' with new audio-tracks '001-russ-audio.mp3' and '002-audio.mp3'. As result you are got correct new containers _while_ containers and audio tracks placed properly. CLI use naive 'sort' function, remember that.

### How to use ###

	Usage: audio_repacker.rb [OPTIONS] AUDIO_DIR

	Specific options:
	    -v, --video [VIDEO_DIR]          Select directory where video files will be coded
	    -o, --output [OUTPUT_DIR]        Select output directory
	        --keep_audio                 Do not wipe out audio tracks from source container

	Common options:
	    -h, --help                       Show this message
	        --version                    Show version

### Example ###

	audio_repacker.rb ./sound_dir/

### Limitation ##

You **MUST** have some number of video and audiofiles, or script return error.