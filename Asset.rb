#
#  Asset.rb
#  Cocoa Slides MacRuby
#
#  Created by Matthew Smith on 9/24/10.
#  Copyright (c) 2010 Apple Inc. All rights reserved.
#

class Asset
  attr_accessor :url, :dateLastUpdated, :fileSize, :previewImage, :includedInSlideShow
  
  def self.fileTypes
    # Subclasses should override this.
    return nil
  end
  
  def initWithURL(newURL)
    self = super.init
    if self
      self.url = newURL
    end
    
    return self
  end
  
  def filename
    return self.url.path.lastPathComponent
  end
  
  def localizedTypeDescription
    error = NSError
    workspace = NSWorkspace.sharedWorkspace
    type = workspace.typeOfFile(self.url.path, error:error)
    if type
      return workspace.localizedDescriptionForType(type)
    else
      "Unrecognized file type"
    end
  end
  
  def fileSize
    # TODO: this is probably not the best way to do this and needs further exploration
    if self.fileSize == 0
      fileManager = NSFileManager.defaultManager
      attributes = fileManager.fileAttributesAtPath(self.url.path, traverseLink:true)
      fileSize = attributes[NSFileSize].unsignedLongLongValue
    end
    return fileSize
  end
  
  def setFileSize(newFileSize)
    # TODO: this is probably not the best way to do this and needs further exploration
    self.fileSize = newFileSize
  end
  
  def loadMetaData
    # Subclasses should override this.
    return false
  end
  
  def loadPreviewImage
    # Subclasses should override this.
    return false
  end
  
  def loadPreviewImageInBackgroundThread(unusedObject)
    self.loadPreviewImage
  end
  
  def requestPreviewImage
    if !self.previewImage
      NSThread.detachNewThreadSelector(:"loadPreviewImageInBackgroundThread:", toTarget:self, withObject:nil)
    end
  end
  
end
