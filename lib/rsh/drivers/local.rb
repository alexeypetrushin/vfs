module Rsh
  module Drivers
    class Local < Abstract
      def bulk &b
        b.call
      end
    
      def upload_file from_local_path, to_remote_path
        FileUtils.copy from_local_path, to_remote_path
      end
    
      def download_file from_remote_path, to_local_path
        FileUtils.copy from_remote_path, to_local_path
      end
    
      def exist? remote_file_path
        File.exist? remote_file_path
      end
    
      alias_method :directory_exist?, :exist?
      alias_method :file_exist?, :exist?
    
      def remove_file remote_file_path
        File.delete remote_file_path
      end    
    
      def create_directory path
        Dir.mkdir path
      end
    
      def remove_directory path
        FileUtils.rm_r path
      end
      
      def upload_directory from_local_path, to_remote_path
        FileUtils.cp_r from_local_path, to_remote_path
      end
      
      def download_directory from_remote_path, to_local_path
        FileUtils.cp_r from_remote_path, to_local_path
      end
    
      def exec command        
        code, stdout, stderr = Open3.popen3 command do |stdin, stdout, stderr, waitth|  
          [waitth.value.to_i, stdout.read, stderr.read]
        end
      
        return code, stdout, stderr
      end
    end
  end
end