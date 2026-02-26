//
//  SGPlayerHeader.h
//  SGPlayer
//
//  Created by Single on 2019/8/14.
//  Copyright © 2019 single. All rights reserved.
//

#ifndef SGPlayerHeader_h
#define SGPlayerHeader_h

#import <Foundation/Foundation.h>

#if __has_include(<HHPlayer/SGPlayer.h>)

FOUNDATION_EXPORT double SGPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char SGPlayerVersionString[];

#import <HHPlayer/SGTime.h>
#import <HHPlayer/SGError.h>
#import <HHPlayer/SGDefines.h>

#import <HHPlayer/SGOptions.h>
#import <HHPlayer/SGDemuxerOptions.h>
#import <HHPlayer/SGDecoderOptions.h>
#import <HHPlayer/SGProcessorOptions.h>

#import <HHPlayer/SGAudioDescriptor.h>
#import <HHPlayer/SGVideoDescriptor.h>

#import <HHPlayer/SGAsset.h>
#import <HHPlayer/SGURLAsset.h>
#import <HHPlayer/SGMutableAsset.h>

#import <HHPlayer/SGTrack.h>
#import <HHPlayer/SGMutableTrack.h>
#import <HHPlayer/SGTrackSelection.h>

#import <HHPlayer/SGSegment.h>
#import <HHPlayer/SGURLSegment.h>
#import <HHPlayer/SGPaddingSegment.h>

#import <HHPlayer/SGDemuxable.h>
#import <HHPlayer/SGURLDemuxer.h>

#import <HHPlayer/SGPlayerItem.h>
#import <HHPlayer/SGFrameReader.h>
#import <HHPlayer/SGFrameOutput.h>
#import <HHPlayer/SGPacketOutput.h>

#import <HHPlayer/SGClock.h>
#import <HHPlayer/SGVRViewport.h>
#import <HHPlayer/SGAudioRenderer.h>
#import <HHPlayer/SGVideoRenderer.h>

#import <HHPlayer/SGData.h>
#import <HHPlayer/SGFrame.h>
#import <HHPlayer/SGCapacity.h>
#import <HHPlayer/SGAudioFrame.h>
#import <HHPlayer/SGVideoFrame.h>

#import <HHPlayer/SGProcessor.h>
#import <HHPlayer/SGAudioProcessor.h>
#import <HHPlayer/SGVideoProcessor.h>

#import <HHPlayer/SGSonic.h>
#import <HHPlayer/SGSWScale.h>
#import <HHPlayer/SGSWResample.h>
#import <HHPlayer/SGAudioMixer.h>
#import <HHPlayer/SGAudioMixerUnit.h>
#import <HHPlayer/SGAudioFormatter.h>

#import <HHPlayer/SGPLFView.h>
#import <HHPlayer/SGPLFImage.h>
#import <HHPlayer/SGPLFColor.h>
#import <HHPlayer/SGPLFObject.h>
#import <HHPlayer/SGPLFScreen.h>
#import <HHPlayer/SGPLFTargets.h>

#elif __has_include(<SGPlayer/SGPlayer.h>)

FOUNDATION_EXPORT double SGPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char SGPlayerVersionString[];

#import <SGPlayer/SGTime.h>
#import <SGPlayer/SGError.h>
#import <SGPlayer/SGDefines.h>

#import <SGPlayer/SGOptions.h>
#import <SGPlayer/SGDemuxerOptions.h>
#import <SGPlayer/SGDecoderOptions.h>
#import <SGPlayer/SGProcessorOptions.h>

#import <SGPlayer/SGAudioDescriptor.h>
#import <SGPlayer/SGVideoDescriptor.h>

#import <SGPlayer/SGAsset.h>
#import <SGPlayer/SGURLAsset.h>
#import <SGPlayer/SGMutableAsset.h>

#import <SGPlayer/SGTrack.h>
#import <SGPlayer/SGMutableTrack.h>
#import <SGPlayer/SGTrackSelection.h>

#import <SGPlayer/SGSegment.h>
#import <SGPlayer/SGURLSegment.h>
#import <SGPlayer/SGPaddingSegment.h>

#import <SGPlayer/SGDemuxable.h>
#import <SGPlayer/SGURLDemuxer.h>

#import <SGPlayer/SGPlayerItem.h>
#import <SGPlayer/SGFrameReader.h>
#import <SGPlayer/SGFrameOutput.h>
#import <SGPlayer/SGPacketOutput.h>

#import <SGPlayer/SGClock.h>
#import <SGPlayer/SGVRViewport.h>
#import <SGPlayer/SGAudioRenderer.h>
#import <SGPlayer/SGVideoRenderer.h>

#import <SGPlayer/SGData.h>
#import <SGPlayer/SGFrame.h>
#import <SGPlayer/SGCapacity.h>
#import <SGPlayer/SGAudioFrame.h>
#import <SGPlayer/SGVideoFrame.h>

#import <SGPlayer/SGProcessor.h>
#import <SGPlayer/SGAudioProcessor.h>
#import <SGPlayer/SGVideoProcessor.h>

#import <SGPlayer/SGSonic.h>
#import <SGPlayer/SGSWScale.h>
#import <SGPlayer/SGSWResample.h>
#import <SGPlayer/SGAudioMixer.h>
#import <SGPlayer/SGAudioMixerUnit.h>
#import <SGPlayer/SGAudioFormatter.h>

#import <SGPlayer/SGPLFView.h>
#import <SGPlayer/SGPLFImage.h>
#import <SGPlayer/SGPLFColor.h>
#import <SGPlayer/SGPLFObject.h>
#import <SGPlayer/SGPLFScreen.h>
#import <SGPlayer/SGPLFTargets.h>

#else

#import "SGTime.h"
#import "SGError.h"
#import "SGDefines.h"

#import "SGOptions.h"
#import "SGDemuxerOptions.h"
#import "SGDecoderOptions.h"
#import "SGProcessorOptions.h"

#import "SGAudioDescriptor.h"
#import "SGVideoDescriptor.h"

#import "SGAsset.h"
#import "SGURLAsset.h"
#import "SGMutableAsset.h"

#import "SGTrack.h"
#import "SGMutableTrack.h"
#import "SGTrackSelection.h"

#import "SGSegment.h"
#import "SGURLSegment.h"
#import "SGPaddingSegment.h"

#import "SGDemuxable.h"
#import "SGURLDemuxer.h"

#import "SGPlayerItem.h"
#import "SGFrameReader.h"
#import "SGFrameOutput.h"
#import "SGPacketOutput.h"

#import "SGClock.h"
#import "SGVRViewport.h"
#import "SGAudioRenderer.h"
#import "SGVideoRenderer.h"

#import "SGData.h"
#import "SGFrame.h"
#import "SGCapacity.h"
#import "SGAudioFrame.h"
#import "SGVideoFrame.h"

#import "SGProcessor.h"
#import "SGAudioProcessor.h"
#import "SGVideoProcessor.h"

#import "SGSonic.h"
#import "SGSWScale.h"
#import "SGSWResample.h"
#import "SGAudioMixer.h"
#import "SGAudioMixerUnit.h"
#import "SGAudioFormatter.h"

#import "SGPLFView.h"
#import "SGPLFImage.h"
#import "SGPLFColor.h"
#import "SGPLFObject.h"
#import "SGPLFScreen.h"
#import "SGPLFTargets.h"

#endif

#endif /* SGPlayerHeader_h */
