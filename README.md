# Pick-a-color

A modern color picker.

Modern computers can display more colors than we can specify with the old `#rrggbb` notation. Also, rgb is not great in a lot of ways. For example it's hard to pick two different hues that have the same "lightness" using RGB.

LCH is a better (my personal opinion) color model, which is more uniform and allows you to express more colors. This is what is used in `pick-a-color`. Unfortunately browsers don't fully support lch colors yet, so we have to convert them to rgb color space. Luckily, we can use `p3`, which is a wider rgb color space.

React concurrent mode is used to make stuff smooth and most of the code is written in ReScript. It's all very alpha.
