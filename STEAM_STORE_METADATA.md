# Steam Store metadata snapshot

Public metadata for the existing Celestia Steam App ID `4753420`, captured on
August 15, 2026. Use this as a starting point when creating the replacement
app, not as an instruction to reuse the old app or package IDs.

Sources:

- [Public store page](https://store.steampowered.com/app/4753420/)
- [Steam Store app-details API](https://store.steampowered.com/api/appdetails?appids=4753420&l=english&cc=us)
- [Public Workshop page](https://steamcommunity.com/app/4753420/workshop/)

This snapshot contains only publicly exposed English/US metadata. Steamworks
does not publicly expose every setting, localized store page, questionnaire
answer, pricing region, launch option, package permission, or original media
file. Recreate and review those fields in the new partner account.

## Identity and commercial fields

| Field | Existing value |
| --- | --- |
| Name | Celestia |
| Type | Game |
| App ID | `4753420` — legacy; do not reuse |
| Package ID | `1653219` — legacy; do not reuse |
| Developer | Celestia Development Team |
| Publisher | Celestia Development Team |
| Genre | Simulation |
| Free | No |
| US price at capture | $1.99 USD |
| Existing release date | June 22, 2026 — do not copy to the new app |
| Required age | 0 |
| Website | https://celestia.mobi |
| Support URL | https://celestia.mobi |
| Support email | `celestia.mobile@outlook.com` |

The incoming maintainer must verify that they are authorized to use the listed
developer/publisher names, website, support address, copy, and media. Replace
the support contact with one they control. The new app should be configured as
Early Access and use its own release timeline, package, and regional pricing.

## Short description

> A real-time 3D space simulator and interactive planetarium. Travel to any
> planet, moon, star, or galaxy and view it from any point in space and time.
> Accelerate time, land on alien worlds, and expand the universe with
> community-made add-ons.

## About this game

### Celestia — real-time 3D visualization of space

**3D Space Simulator | Celestia lets you explore our universe in three
dimensions.**

Celestia simulates many different types of celestial objects. From planets and
moons to star clusters and galaxies, you can visit every object in the
expandable database and view it from any point in space and time. The position
and movement of solar system objects is calculated accurately in real time at
any rate desired.

**Interactive Planetarium | Celestia serves as a planetarium – for an observer
on any celestial object.**

You can easily navigate to any world and land on its surface. When used as a
planetarium, Celestia shows accurate positions of solar system objects in the
sky. You can switch labels and other supporting features on and off with
hotkeys, or zoom in and out on an object of interest, for example Jupiter’s
system of moons.

**Expandable Content | Customize Celestia according to your needs.**

Celestia’s catalogues can be easily expanded. There are many different add-ons
available containing new objects like comets or stars, high-resolution
textures of Earth and other well mapped solar system bodies, as well as 3D
models for asteroids and spacecraft on precise trajectories. Even fictional
objects from well-known sci-fi franchises can be found.

*Music used in trailer: "Brittle Rille" Kevin MacLeod. Licensed under Creative
Commons: By Attribution 3.0 License.*

The API returned the same text for `detailed_description` and
`about_the_game`.

## Early Access copy to add

The old app was not marked as Early Access and therefore has no reusable Early
Access questionnaire text. The new maintainer must write accurate, current
answers for:

- why the app is in Early Access;
- how long it is expected to remain there;
- how the planned full version differs;
- the current state of the Early Access version;
- whether pricing will change; and
- how the community will participate in development.

Do not make promises about dates, features, updates, or pricing that cannot be
supported.

## Platforms and features

| Field | Existing value |
| --- | --- |
| Windows | Yes |
| macOS | No |
| Linux | No |
| Single-player | Yes |
| Steam Workshop | Yes |
| Playable at your own pace | Yes |
| Playable without timed input | Yes |
| Family Sharing | Yes |

The Steamworks Windows launch option should point to `celestia-qt6.exe`.

The public Workshop page description is:

> Subscribe to community add-ons and scripts for Celestia: extra celestial
> objects, high-resolution textures, 3D models, and guided tours. Subscribed
> items load automatically when you launch Celestia.

## Supported languages

- English
- French
- Italian
- German
- Spanish - Spain
- Arabic
- Bulgarian
- Dutch
- Greek
- Hungarian
- Japanese
- Korean
- Norwegian
- Polish
- Portuguese - Brazil
- Portuguese - Portugal
- Romanian
- Russian
- Simplified Chinese
- Spanish - Latin America
- Swedish
- Traditional Chinese
- Turkish
- Ukrainian

The public API does not distinguish interface, subtitles, and full-audio
support in this response. Verify each language against the current build
before selecting it in the replacement app.

## Windows system requirements

### Minimum

- Requires a 64-bit processor and operating system
- **OS:** Windows 7 SP1 / Windows 10 (64-bit)
- **Processor:** Dual-core 2.0 GHz (Intel Core 2 Duo / AMD equivalent)
- **Memory:** 2 GB RAM
- **Graphics:** OpenGL 3.3-capable GPU with 1 GB VRAM (Intel HD 4000 / NVIDIA
  GeForce GT 430 / AMD Radeon HD 5670 or better)
- **Storage:** 500 MB available space
- **Additional:** Internet connection required for Workshop content

### Recommended

- Requires a 64-bit processor and operating system
- **OS:** Windows 11 (64-bit)
- **Processor:** Quad-core 3.0 GHz (Intel i5-6600K / AMD Ryzen 5 1600 or
  better)
- **Memory:** 8 GB RAM
- **Graphics:** OpenGL 4.x-capable GPU with 2 GB VRAM (NVIDIA GTX 1050 / AMD
  RX 560 or better)
- **Storage:** 2 GB available space
- **Additional:** Internet connection required for Workshop content

Revalidate these requirements against the final replacement build. Windows 7
was already marked with Steam's legacy-OS indicator in the old listing.

## Content descriptors and ratings

The public API returned no Steam content-descriptor IDs or notes.

| Rating system | Existing public value |
| --- | --- |
| Germany | Generated rating `0`; required age `0` |
| IGRS | Generated rating `3`; required age `0` |
| DejUS | Generated rating `L`; required age `0` |

Complete all content surveys again for the new app rather than assuming these
generated ratings will transfer.

## Public media

All 39 publicly exposed graphics have been downloaded to
[`steam-metadata/graphics/`](steam-metadata/graphics/README.md), including
store, client, library, screenshot, and trailer-thumbnail variants. Upload
authorized files through the new app's Steamworks graphical-assets and
store-page tools.

### Capsules and backgrounds

- [Header image, 460x215](steam-metadata/graphics/store/header.jpg)
- [Main capsule, 616x353](steam-metadata/graphics/store/capsule_616x353.jpg)
- [Small capsule, 231x87](steam-metadata/graphics/store/capsule_231x87.jpg)
- [Small capsule v5, 184x69](steam-metadata/graphics/store/capsule_184x69.jpg)
- [Raw page background, 1438x810](steam-metadata/graphics/store/page_bg_raw.jpg)
- [Generated page background, 1438x810](steam-metadata/graphics/store/page_bg_generated.jpg)
- [Client/community icon, 32x32](steam-metadata/graphics/client/icon.jpg)

### Library assets

- [Library capsule, 300x450](steam-metadata/graphics/library/library_capsule.jpg)
- [Library capsule 2x, 600x900](steam-metadata/graphics/library/library_capsule_2x.jpg)
- [Library hero, 1920x620](steam-metadata/graphics/library/library_hero.jpg)
- [Library hero 2x, 3840x1240](steam-metadata/graphics/library/library_hero_2x.jpg)
- [Generated blurred hero, 192x62](steam-metadata/graphics/library/library_hero_blur.jpg)
- [Library logo, 640x100](steam-metadata/graphics/library/logo.png)
- [Library logo 2x, 1280x199](steam-metadata/graphics/library/logo_2x.png)
- [Library header, 460x215](steam-metadata/graphics/library/library_header.jpg)
- [Library header 2x, 920x430](steam-metadata/graphics/library/library_header_2x.jpg)

The old app positioned its library logo at the bottom left with width
`41.41876430205948%` and height `63.29850391830919%`.

### Screenshots

Each screenshot is archived in thumbnail, standard, and full-size variants:

1. [Screenshot 1, full size](steam-metadata/graphics/screenshots/01_full_1920x1080.jpg)
2. [Screenshot 2, full size](steam-metadata/graphics/screenshots/02_full_1920x1080.jpg)
3. [Screenshot 3, full size](steam-metadata/graphics/screenshots/03_full_1920x1080.jpg)
4. [Screenshot 4, full size](steam-metadata/graphics/screenshots/04_full_1920x1080.jpg)
5. [Screenshot 5, full size](steam-metadata/graphics/screenshots/05_full_1920x1080.jpg)
6. [Screenshot 6, full size](steam-metadata/graphics/screenshots/06_full_1920x1080.jpg)
7. [Screenshot 7, full size](steam-metadata/graphics/screenshots/07_full_1920x1080.jpg)

### Trailer

| Field | Existing value |
| --- | --- |
| Name | Celestia Trailer |
| Movie ID | `257339726` |
| Highlighted | Yes |
| Thumbnail | [600x337 image](steam-metadata/graphics/trailer/movie_600x337.jpg) |
| Stream | [HLS manifest](https://video.akamai.steamstatic.com/store_trailers/4753420/1588757861/6d060e8dbd8a2a4c7dc9e839c849238a7d1d223c/1779236935/hls_264_master.m3u8) |

The stream manifest is not a substitute for the authorized source video.
Retain the trailer attribution shown in the store description and verify all
music, footage, logo, and distribution rights before re-uploading it.

## Fields that must be recreated manually

- Early Access status and questionnaire
- App ID, depot ID, package ID, and ownership permissions
- Regional prices and release discounts
- Release date and Coming Soon page
- Windows launch option
- Build branches and passwords
- Workshop configuration, branding, legal acceptance, and contributor access
- Store and community graphical assets not returned by the public API
- Localized descriptions and localized graphical assets
- Content surveys, ratings, and disclosures
- Privacy disclosures and Sentry/crash-reporting disclosures, if enabled
- Support contacts controlled by the incoming maintainer
- Store-page and build-review submissions
