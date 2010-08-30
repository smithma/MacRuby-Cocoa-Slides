#
#  BrowserWindowController.rb
#  Cocoa Slides MacRuby
#
#  Created by Matthew Smith on 8/28/10.
#  Copyright (c) 2010 Apple Inc. All rights reserved.
#

class BrowserWindowController < NSWindowController
  # Model
  attr_accessor :path, :assetCollection
  
  # Views
  attr_accessor :assetCollectionView
  
  # Controllers
  attr_accessor :slideshowWindowController
  
  # UI State
  attr_accessor :sortKey, :sortsAscending


  
  def initWithPath(newPath)
    self.initWithWindowNibName("BrowserWindow")
    if self
      self.path = newPath
      self.sortKey = "filename"
      self.sortsAscending = true
    end
    return self
  end
  
  def updateSortDescriptors
    # Build a new NSSortDescriptor that we can use to order our image assets, according to the current "sortKey" and "sortsAscending" setting.
    effectiveSortKey = "asset.#{self.sortKey}"
    if self.sortKey == "filename"
      sortDescriptor = NSSortDescriptor.alloc.initWithKey(effectiveSortKey, ascending: self.sortsAscending, selector: :"caseInsensitiveCompare:")
    else
      sortDescriptor = NSSortDescriptor.alloc.initWithKey(effectiveSortKey, ascending: self.sortsAscending)
    end
    
    # Tell our AssetCollectionView to use the new sort descriptor.
    self.assetCollectionView.setSortDescriptors([sortDescriptor])
  end
  
  def setSortKey(newSortKey)
    if self.sortKey != newSortKey
      self.sortKey = newSortKey
      self.updateSortDescriptors
    end
  end
  
  def setSortsAscending(flag)
    if self.sortsAscending != flag
      self.sortsAscending = flag
      self.updateSortDescriptors
    end
  end
  
  def windowDidLoad
    # Ask for assetCollectionView and all its descendants to be rendered and animated using layers.  Note that this is the only part of this code sample that refers in any way to the existence of layers. -- AppKit takes care of the implications of this automatically!  Interface Builder 3.0 even allows the per-view "wantsLayer" flag to be set in the .nib, which would allow removing these two lines of code.
    self.assetCollectionView.setWantsLayer = true
    
    # Create an AssetCollection for browsing our assigned path.
    self.assetCollection = AssetCollection.alloc.initWithRootURL(NSURL.fileURLWithPath(self.path))
    
    # Set the window's title to the name of the folder we're browsing.
    self.assetCollectionView.window.setTitle(self.path.lastPathComponent)
    
    # Hook things up and start loading thumbnails.
    self.updateSortDescriptors
    self.assetCollectionView.setAssetCollection(assetCollection)
    self.assetCollection.startRefresh
  end
  
  def windowDidBecomeKey(notification)
    # Rescan for filesystem changes each time window becomes key again.
    self.assetCollection.startRefresh
  end
  
  def refresh(sender)
    # Ask our assetCollection to check for new, changed, and removed asset files.  Our assetCollectionView will be automatically notified of any changes to the assetCollection via KVO.
    self.assetCollection.startRefresh
    
  end
  
  def showSlideshowWindow(sender)
    self.slideshowWindowController.setAssetCollection(assetCollection)
    self.slideshowWindowController.showWindow(self)
  end
  
end

