module Vfs
  class File < Entry
    # 
    # Attributes
    # 
    alias_method :exist?, :file?
    
    
    #
    # CRUD
    #
    def read raise_if_not_exist = true, &block
      if block
        storage.read_file path, &block
      else
        data = ""
        storage.read_file(path){|buff| data << buff}
        data
      end
    rescue StandardError => e
      raise Vrs::Error, "can't read Dir #{self}!" if dir.exist?
      attrs = get
      if attrs[:file]
        # unknown internal error
        raise e
      elsif attrs[:dir]
        raise Error, "You are trying to read Dir '#{self}' as if it's a File!"
      else
        if raise_if_not_exist
          raise Error, "file #{self} not exist!"
        else
          block ? block.call('') : ''
        end        
      end      
    end
    
    def create override = false
      write '', override
    end    
    def create!
      create true
    end
        
    def write *args, &block
      if block
        override = args.first
        storage.write_file(path, &block)
      else
        data, override = *args
        storage.write_file(path){|writer| writer.call data}
      end
    rescue StandardError => error
      entry = self.entry
      if entry.exist?
        if override
          entry.destroy
        else
          raise Error, "entry #{self} already exist!"
        end
      else
        parent = self.parent
        if parent.exist?
          # some unknown error
          raise error          
        else
          parent.create(override)        
        end
      end
      
      retry
    end    
    def write! *args, &block
      args << true
      write *args, &block
    end
    
    def destroy force = false
      storage.delete_file path          
    rescue StandardError => e
      attrs = get
      if attrs[:dir]
        if force
          dir.destroy          
        else
          raise Error, "can't destroy Dir #{dir} (you are trying to destroy it as if it's a File)"
        end
      elsif attrs[:file]
        # unknown internal error
        raise e
      else
        # do nothing, file already not exist
      end
    end
    def destroy!
      destroy true
    end
  end
end