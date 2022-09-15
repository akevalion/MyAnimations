# MyAnimations
my personal creations

To used download last version of Roassal3 in pharo11.

```st
[Metacello new
    baseline: 'Roassal3';
    repository: 'github://ObjectProfile/Roassal3';
    load.
Metacello new
    baseline: 'Roassal3Exporters';
    repository: 'github://ObjectProfile/Roassal3Exporters';
    load: 'Video'.
Metacello new
    baseline: 'AIImageSegmentation';
    repository: 'github://pharo-ai/image-segmentation';
    load.
    ] on: MCMergeOrLoadWarning do: [:warning | warning load ]
```
