#
#  AssetCollection.rb
#  Cocoa Slides MacRuby
#
#  Created by Matthew Smith on 8/30/10.
#  Copyright (c) 2010 Apple Inc. All rights reserved.
#

class AssetCollection < NSObject
  attr_accessor :rootURL, :assets, :previewImagePixelsPerSide, :inRefresh
  
  def initWithRootURL(newRootURL)
    super.init
    self.rootURL = newRootURL
    self.assets = []
    self.previewImagePixelsPerSide = 80
    return self
  end
  
  def setAssets(newAssets)
    if assets != newAssets
      assets = newAssets
    end
  end
  
  def insertObject(obj, inAssetsAtIndex:index)
    self.assets.insertObject(obj, atIndex:index)
  end
  
  def removeObjectFromAssetsAtIndex(index)
    self.assets.removeObjectAtIndex(index)
  end
  
  # *** Background Update Control ***
  
  def refreshInBackgroundThread(unusedObject)
    # Get a list of all the possible image files in root directory.
    assetFiles = self.findAssetFilesInRootURL

    # Identify three groups of image files:
    # (1) files that are in the catalog, but have since changed (the file's modification date is later than its last-cached date)
    # (2) files that exist on disk but are not yet in the catalog (presumably the file was added and we should create a catalog entry for it)
    # (3) files that exist in the catalog but not on disk (presumably the file was deleted and we should remove the corresponding catalog entry)
    asset = Asset.new
    fileManager = NSFileManager.defaultManager
    rootPath = self.rootURL.path
    fileEnumerator = assetFiles.objectEnumerator
    filename = ""
    while filename = fileEnumerator.nextObject
      # Get full path to file.
      path = rootPath + filename
      
      # Look for a corresponding entry in the catalog
      asset = self.assetForFileName(filename)
      if asset
        # Check whether file has changed.
        fileAttributes = fileManager.fileAttributesAtPath(path, traverseLink:true)
        if fileAttributes
          # Get file's modification date.
          fileModificationDate = fileAttributes.objectForKey("NSFileModificationDate")
          if fileModificationDate.compare(asset.dateLastUpdated) == NSOrderedDescending
            assetsChanged.addObject(asset)
          end
        else
          # NOTE: This shouldn't ever really happen, unless the file was deleted between our initial scan and getting to the file attribute check, but just in case, allow for the file to have been removed in that interval.
          assetsRemoved.addObject(asset)
        end
        
        # We've dealt with this catalogImage instance.
        assetsToProcess.removeObject(asset)
      else
        
        # File was added.
        filesAdded.addObject(filename)
      end
    end
    
    # Check for images in the catalog for which no corresponding file was found.
    assetsRemoved.addObjectsFromArray(assetsToProcess)
    assetsToProcess = nil
    
    # Remove addets to be removed.
    assetEnumerator = assetsRemoved.objectEnumerator
    while asset = assetEnumerator.nextObject
      self.performSelectorOnMainThread(:"removeAsset:", withObject:asset, waitUntilDone:true);
    end
    
    # Add assets to be added.
    fileEnumerator = filesAdded.objectEnumerator
    while filename = fileEnumerator.nextObject
      assetURL = NSURL.URLWithString(filename.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding), relativeToURL:self.rootURL);
      extension = filename.pathExtension
      asset = Asset.new
      if ImageAsset.fileTypes.containsObject(extension)
        asset = ImageAsset.alloc.initWithURL(assetURL)
      end
      if asset
        self.performSelectorOnMainThread(:"addAsset:", withObject:asset waitUntilDone:true)
        asset = nil
      end
    end
    self.inRefresh = false
  end
  
  def startRefresh
    if !self.inRefresh
      inRefresh = true
      NSThread detachNewThreadSelector(:"refreshInBackgroundThread:", toTarget:self, withObject:nil)
    end
  end
  
  #pragma mark *** Main Thread Callback Points ***
  
  def addAsset(asset)
    self.insertObject(asset, inAssetsAtIndex:assets.count)
  end
  
  def removeAsset(asset)
    index = assets.indexOfObject(asset)
    if index != NSNotFound
      self.removeObjectFromAssetsAtIndex(index)
    end
  end
  
  # Internals
  
  def assetForFileName(filename)
    # (Use of a dictionary or other more search-efficient construct would speed this up.)
    self.assets.each do |asset|
      if filename.isEqualToString(asset.filename)
        return asset
      end
    end
    return nil
  end
  
  def findAssetFilesInRootURL
    rootPath = self.rootURL.path
    fileManager = NSFileManager.defaultManager
    possibileAssetFiles = fileManager.directoryContentsAtPath(rootPath)
    supportedAssetFileTypes = ImageAsset.fileTypes
    assetFiles = []
    
    possibileAssetFiles.each do |filename|
      # (In a real-world application, if we have a filename with no extension, we should be prepared to check the file's HFS type code or other identifying metadata here.)
      if supportedAssetFileTypes.containsObject(filename.pathExtension)
        assetFiles.addObject(filename)
      end
    end
    
    return assetFiles
  end
  
end