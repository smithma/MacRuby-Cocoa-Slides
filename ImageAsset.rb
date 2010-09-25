#
#  ImageAsset.rb
#  Cocoa Slides MacRuby
#
#  Created by Matthew Smith on 9/24/10.
#  Copyright (c) 2010 Apple Inc. All rights reserved.
#

class ImageAsset
  attr_accessor :imageProperties, :imageSource, :url, :previewImage
  
  def self.fileTypes
    return NSImage.imageFileTypes
  end
  
  def pixelsWide
    if !self.imageProperties
      self.loadMetadata
    end
    return imageProperties["kCGImagePropertyPixelWidth"].to_i
  end
  
  def pixelsHigh
    if !self.imageProperties
      self.loadMetadata
    end
    return imageProperties["kCGImagePropertyPixelHeight"].to_i
  end
  
  # Many kinds of image files contain prerendered thumbnail images that can be quickly loaded without having to decode the entire contents of the image file and reconstruct the full-size image.  The ImageIO framework's CGImageSource API provides a means to do this, using the CGImageSourceCreateThumbnailAtIndex() function.  For more information on CGImageSource objects and their capabilities, see the CGImageSource reference on the Apple Developer Connection website, at http://developer.apple.com/documentation/GraphicsImaging/Reference/CGImageSource/Reference/reference.html
  def createImageSource
    if !self.imageSource
      # Compose absolute URL to file.
      sourceURL = self.url.absoluteURL
      if sourceURL == nil
        return false
      end
      
      # Create a CGImageSource from the URL.
      imageSource = CGImageSourceCreateWithURL(sourceURL, nil)
      if imageSource == nil
        return false
      end
      
      imageSourceType = CGImageSourceGetType(imageSourceType)
      if imageSourceType == nil
        return false
      end
      
      return true
      
    end
  end

  def loadMetadata
    if self.imageProperties == nil
      if !self.createImageSource
        return false
      end
      
      # This code looks at the first image only.  To be truly general, we'd need to handle the possibility of an image source having more than one image to offer us.
      index = 0
      self.imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil)
    end
    
    # Return indicating success!
    if self.imageProperties
      return true
    else
      return false
    end
  end

  def loadPreviewImage
    success = false
    
    if !self.createImageSource
      return false
    end
    
    # Ask ImageIO to create a thumbnail from the file's image data, if it can't find a suitable existing thumbnail image in the file.  We could comment out the following line if only existing thumbnails were desired for some reason (maybe to favor performance over being guaranteed a complete set of thumbnails).
    options = {"kCGImageSourceCreateThumbnailFromImageIfAbsent" => true, "kCGImageSourceThumbnailMaxPixelSize" => 160}
    
    thumbnail = CGImageSourceCreateThumbnailAtIndex(self.imageSource, 0, options)
    
    image = NSImage.alloc.initWithCGImage(thumbnail)
    self.performSelectorOnMainThread(:"setPreviewImage:", withObject:image, waitUntilDone:false)
    if image
      success = true
    end
    
    return success
  end

end
