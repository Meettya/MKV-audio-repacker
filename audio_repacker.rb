#!/usr/bin/env ruby
# encoding: UTF-8
BEGIN {$VERBOSE = true}

VERSION = '0.4.1'

require 'optparse'
require 'ostruct'
require 'pathname'
require 'fileutils'
require 'shellwords'
require 'pp'

#===================================
# Some different halpers class
#===================================

class OptparseRepacker
  
  # default settings for directories
  DEFAULT_OUTPUT_DIR_NAME = "./repacked"
  DEFAULT_VIDEO_DIR_NAME  = "./"
  
  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.video = DEFAULT_VIDEO_DIR_NAME
    options.audio = nil
    options.output = DEFAULT_OUTPUT_DIR_NAME

    opts_obj = OptionParser.new do |opts|
      opts.banner = "Usage: audio_repacker.rb [OPTIONS] AUDIO_DIR"

      opts.separator ""
      opts.separator "Specific options:"

      # String argument.
      opts.on("-v", "--video [VIDEO_DIR]",
              "Select directory where", " video files will be coded") do |video|
        options.video = video
      end

      # String argument.
      opts.on("-o", "--output [OUTPUT_DIR]",
              "Select output directory") do |output|
        options.output = output
      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      # Another typical switch to print the version.
      opts.on_tail("--version", "Show version") do
        puts VERSION
        exit
      end
    end

    # now parse all
    opts_obj.parse!(args)
  
    # Add audio_dir 
    if args.length != 1
      puts "Missing audio_dir argument (try --help)"
      exit
    end
    options.audio = ARGV.shift    

    options
  end  # parse()

end  # class OptparseRepacker

class RepackerInitialazer
 
  VIDEO_FILES_EXTENTION = 'mkv' # only 'mkv' files agreed
  AUDIO_FILES_EXTENTION = '*' # any audiofiles agreed
  #
  # Return a hash of video_files => audio_files to proceed.
  #
  def self.prepare(audiodir, videodir)

    # get all files
    video_files = FileFinder.find_files videodir, "*." << VIDEO_FILES_EXTENTION
    audio_files = FileFinder.find_files audiodir, "*." << AUDIO_FILES_EXTENTION

    unless video_files.size == audio_files.size
      puts "Error: different sizes, can`t proceed \n \tvideo_dir |#{videodir}| - |#{video_files.size}| files \n\taudio_dir |#{audiodir}| |#{audio_files.size}| files" 
      exit
    end #unless
    
    # pack all in hash (video => audio) and return it
    Hash[video_files.zip audio_files]

  end # prepare()

  # return all existings files in output directory to awoid re-packing
  def self.existings(outputdir)
    FileFinder.find_files outputdir, "*." << VIDEO_FILES_EXTENTION   
  end #existings()

end # class RepackerInitialazer

class PathCompiller
  ###
  # Compile full patch from args
  ###

  #Compile full path
  def self.compile(arg)

    test_dir = Pathname.new arg
    test_dir.absolute? ? test_dir : File.expand_path(arg)

  end #compile()
  
end #class PathCompiller

# search files in directory
# return sorted array
class FileFinder
  
  def self.find_files( dir, pattern="*" )
    result = Array.new
    
    Dir.chdir(dir) do 
      result = Dir[pattern].sort #! yap, its sorted
    end # Dir.chdir(dir)
    
    result
  end #find_files( dir, pattern="*" )
  
end # class FileFinder

#===================================
# Now start main() part
#===================================

options = OptparseRepacker.parse ARGV

outputdir   = PathCompiller.compile options.output
audiodir    = PathCompiller.compile options.audio
videodir    = PathCompiller.compile options.video

# just simply test is it possible?
unless File.exists?(audiodir)
  puts "Error: not exists audio_dir |#{options.audio}| with fullpatch |#{audiodir}|"
  exit
end #unless

# we need outputdir anyway
FileUtils.makedirs(outputdir, :mode => 0775 ) unless File.exists?(outputdir)

prepared_pairs = RepackerInitialazer.prepare audiodir, videodir
existings_files = RepackerInitialazer.existings outputdir

# wipe out proceesed before to awoid re-packing
pairs_to_proceed = prepared_pairs.delete_if do |key, value|
  if existings_files.index(key)
     puts "\tINFO: file #{key} exists in repack dir, skipped..." 
     true
  end # if 
end #prepared_pairs.delete_if do 

# proceed repacking
pairs_to_proceed.each_pair do |key, value|
  exec_str = %Q[mkvmerge -A -o #{Shellwords.escape File.join(outputdir, key )} #{Shellwords.escape File.join(videodir, key )} #{Shellwords.escape File.join(audiodir, value )}]
  # pp "#{key} -> #{value}"
  system exec_str
  
end # prepared_pairs.each_pair do

