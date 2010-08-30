#
#  SlideShowWindowController.rb
#  Cocoa Slides MacRuby
#
#  Created by Matthew Smith on 8/29/10.
#  Copyright (c) 2010 Apple Inc. All rights reserved.
#

class SlideShowWindowController < NSWindowController
  
  # Model
  attr_accessor :assetCollection
  
  # Views
  attr_accessor :slideshowView
  
  # UI State
  attr_accessor :slideshowCurrentAsset, :slideshowInterval, :slideshowTimer
  
  def startSlideshowTimer
    if !self.slideshowTimer && self.slideshowInterval > 0.0
      # Schedule an ordinary NSTimer that will invoke -advanceSlideshow: at regular intervals, each time we need to advance to the next slide.
      self.slideshowTimer = NSTimer.scheduledTimerWithTimeInterval( self.slideshowInterval, 
                                                                    target: self,
                                                                    selector: :"advanceSlideshow:",
                                                                    userInfo: nil,
                                                                    repeats: true)
      
    end
  end
  
  def stopSlideshowTimer
    if self.slideshowTimer
      slideshowTimer.invalidate
      slideshowTimer = nil
    end
  end
  
  def dealloc
    self.stopSlideshowTimer
    super.dealloc
  end
  
  def setAssetCollection(newAssetCollection)
    if self.assetCollection != newAssetCollection
      self.assetCollection = newAssetCollection
    end
  end
  
  def setSlideshowInterval(newSlideshowInterval)
    if self.slideshowInterval != newSlideshowInterval
      # Stop the slideshow, change the interval as requested, and then restart the slideshow (if it was running already).
      self.stopSlideshowTimer
      self.slideshowInterval = newSlideshowInterval
      if self.slideshowInterval > 0.0
        self.startSlideshowTimer
      end
    end
  end
  
  def awakeFromNib
    # Ask for the slideshowView and its descendants to be rendered and animated using layers.  Note that this is the only part of this code sample that refers in any way to the existence of layers. -- AppKit takes care of the implications of this automatically!  Interface Builder 3.0 even allows the per-view "wantsLayer" flag to be set in the .nib, which would allow removing these two lines of code.
    self.slideshowView.setWantsLayer(true)
    
    # Set default interval for advancing to the next slide.
    self.setSlideshowInterval(3.0)
  end
  
  def advanceSlideshow(timer)
    assets = self.assetCollection.assets
    count = assets.count
    if assets && count > 0 && self.window.isVisible
      # Find the next Asset in the slideshow.
      startIndex = assets.indexOfObject(slideshowCurrentAsset) || 0
      index = (startIndex + 1) % count
      while index != startIndex do
        asset = assets[index]
        if asset.includedInSlideshow
          # Load the full-size image.
          image = NSImage.alloc.initWithContentsOfURL(asset.url)
          
          # Ask our SlideshowView to transition to the image
          self.slideshowView.transitionsToImage(image)
          
          # Remember which slide we're now displaying.
          self.slideshowCurrentAsset = asset
          return
        end
        index = (index + 1) % count
      end
      
    end
  end
end

















