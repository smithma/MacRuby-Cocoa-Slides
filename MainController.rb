#
#  MainController.rb
#  Cocoa Slides MacRuby
#
#  Created by Matthew Smith on 8/28/10.
#  Copyright (c) 2010 Apple Inc. All rights reserved.
#

class MainController < NSResponder
  
  def openBrowserWindow(sender)
    openPanel = NSOpenPanel.openPanel
    openPanel.setCanChooseDirectories(true)
    openPanel.setCanChooseFiles(false)
    result = openPanel.runModalForDirectory("~/Pictures".stringByExpandingTildeInPath, file:nil, types:nil)
    if result == NSOKButton
      self.openBrowserWindowForPath(openPanel.filenames[0])
    end
  end
  
  def openBrowserWindowForPath(path)
    exists = NSFileManager.defaultManager.fileExistsAtPath(path, isDirectory:false)
    if exists
      browserWindowController = BrowserWindowController.alloc.initWithPath(path)
      if browserWindowController
        browserWindowController.showWindow(self)
        return true
      end
    else
      if exists
        informativeText = "Path exists but isn't a directory #{path}"
      else
        informativeText = "Path doesn't exist #{path}"
      end
      NSAlert.alertWithMessage("Can't browse path", defaultButton:"OK", 
                                                    alternateButton:nil, 
                                                    otherButton:nil, 
                                                    informativeTextWithFormat:informativeText).runModal
    end
    return false
  end
  
  def browseNatureDesktopPictures(sender)
    self.openBrowserWindowForPath("/Library/Desktop Pictures/Nature/")
  end
  
  def browsePlantsDesktopPictures(sender)
    self.openBrowserWindowForPath("/Library/Desktop Pictures/Plants/")
  end
  
  def browseBeachScreenSaverPictures(sender)
    self.openBrowserWindowForPath("/System/Library/Screen Savers/Beach.slideSaver/Contents/Resources/")
  end
  
  def browseCosmosScreenSaverPictures(sender)
    self.openBrowserWindowForPath("/System/Library/Screen Savers/Cosmos.slideSaver/Contents/Resources/")
  end
  
  def browseForestScreenSaverPictures(sender)
    self.openBrowserWindowForPath("/System/Library/Screen Savers/Forest.slideSaver/Contents/Resources/")
  end
  
  def browseNaturePatternsScreenSaverPictures(sender)
    self.openBrowserWindowForPath("/System/Library/Screen Savers/Nature Patterns.slideSaver/Contents/Resources/")
  end
  
  def browsePaperShadowScreenSaverPictures(sender)
    self.openBrowserWindowForPath("/System/Library/Screen Savers/Paper Shadow.slideSaver/Contents/Resources/")
  end
  
  def applicationShouldOpenUntitledFile(sender)
    return false
  end
  
  def applicationDidFinishLauching(notification)
    path = "~/Pictures/All Desktop Pictures".stringByExpandingTildeInPath
    exists = NSFileManager.defaultManager.fileExistsAtPath(path, isDirectory:false)
    if exists
      self.openBrowserWindowForPath(path)
    else
      self.browseNatureDesktopPictures(self)
    end
  end
  
end
