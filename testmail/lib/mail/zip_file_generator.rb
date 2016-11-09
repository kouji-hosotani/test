require 'zip'

# This is a simple example which uses rubyzip to
# recursively generate a zip file from the contents of
# a specified directory. The directory itself is not
# included in the archive, rather just its contents.
#
# Usage:
#   directoryToZip = "/tmp/input"
#   outputFile = "/tmp/out.zip"
#   zf = ZipFileGenerator.new(directoryToZip, outputFile)
#   zf.write()
class ZipFileGenerator

  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input, outputFile)
    @input = input
    @outputFile = outputFile
  end

  # Zip the input directory.
  def write()
    if File.directory?(@input)
      entries = Dir.entries(@input)
      entries.delete(".")
      entries.delete("..")
    else
      entries = [File.basename(@input)]
      @input = File.dirname(@input)
    end
    io = Zip::File.open(@outputFile, Zip::File::CREATE);

    writeEntries(entries, "", io)
    io.close();
  end

  # A helper method to make the recursion work.
  private
  def writeEntries(entries, path, io)

    entries.each { |e|
      zipFilePath = path == "" ? e : File.join(path, e)
      diskFilePath = File.join(@input, zipFilePath)
      # macだとこれのせいでうまくofficeにならない
      unless File.basename(diskFilePath) == ".DS_Store"
        puts "Deflating " + diskFilePath
        if File.directory?(diskFilePath)
          io.mkdir(zipFilePath)
          subdir = Dir.entries(diskFilePath)
          subdir.delete(".")
          subdir.delete("..")
          writeEntries(subdir, zipFilePath, io)
        else
          io.get_output_stream(zipFilePath) { |f| f.puts(File.open(diskFilePath, "rb").read())}
        end
      end
    }
  end

end
