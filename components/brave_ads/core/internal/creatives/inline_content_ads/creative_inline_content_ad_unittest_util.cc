/* Copyright (c) 2021 The Brave Authors. All rights reserved.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at https://mozilla.org/MPL/2.0/. */

#include "brave/components/brave_ads/core/internal/creatives/inline_content_ads/creative_inline_content_ad_unittest_util.h"

#include "base/check.h"
#include "brave/components/brave_ads/core/internal/creatives/creative_ad_info.h"
#include "brave/components/brave_ads/core/internal/creatives/creative_ad_unittest_util.h"
#include "brave/components/brave_ads/core/internal/creatives/inline_content_ads/creative_inline_content_ad_info.h"
#include "brave/components/brave_ads/core/internal/segments/segment_unittest_constants.h"
#include "url/gurl.h"

namespace brave_ads {

CreativeInlineContentAdList BuildCreativeInlineContentAdsForTesting(
    const int count) {
  CHECK_GT(count, 0);

  CreativeInlineContentAdList creative_ads;

  for (int i = 0; i < count; i++) {
    CreativeInlineContentAdInfo creative_ad =
        BuildCreativeInlineContentAdForTesting(
            /*should_use_random_uuids*/ true);
    creative_ad.segment = kSegments[i % std::size(kSegments)];

    creative_ads.push_back(creative_ad);
  }

  return creative_ads;
}

CreativeInlineContentAdInfo BuildCreativeInlineContentAdForTesting(
    const bool should_use_random_uuids) {
  const CreativeAdInfo creative_ad =
      BuildCreativeAdForTesting(should_use_random_uuids);
  CreativeInlineContentAdInfo creative_inline_content_ad(creative_ad);

  creative_inline_content_ad.title = "Test Ad Title";
  creative_inline_content_ad.description = "Test Ad Description";
  creative_inline_content_ad.image_url = GURL("https://brave.com/image");
  creative_inline_content_ad.dimensions = "200x100";
  creative_inline_content_ad.cta_text = "Call to action text";

  return creative_inline_content_ad;
}

}  // namespace brave_ads
