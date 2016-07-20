# CLItexties

Post to txti.es from the commandline.

### Usage

Simply use `CLItexties.sh -i` to enter the content and a custom url/editcode interactivly.

Or use `CLItexties.sh -f [path to file] [custom URL] [custom edit code]` to post the contents of a file. To simplify the usage with scripts if a custom URL is already in use, you get a _randomized_ one, to make sure posting never fails if used non-interactivly.

If you used `MyCoolPost` as customized URL you'll find your post at `http://txti.es/MyCoolPost` and the edit link would be `http://txti.es/MyCoolPost/edit`.

### Dependencies

* `curl`
* `lynx`
* `nano`
