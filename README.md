# CLItexties

Post to [txti.es](txti.es) from the command line.

## Usage

    Usage: CLItxties.sh [-h] (-i [-e editor | -f file] (-r | url) | (-f file | -s) (-r | url) edit_code)
      -e editor use a different editor instead of the default nano(1)
      -f file   get the content from a file
      -h        print this usage and exit
      -i        enter the content, the url and the edit code interactively
      -r        use a randomly generated url
      -s        take input from the stdin

## Examples

* Enter the content, the custom url and the edit code interactivly:

        ./CLItxties.sh -i

* Post a content from a file to a random url interactively:

        ./CLItxties.sh -i -f file.txt -r

* Pipe the content into the scipt and post it on `YourCoolURL` using `rad!` as your edit code:

        ./CLItxties.sh -s YourCoolURL rad!

* Enter the content interactively using ed(1), the standard text editor:

        ./CLItxties.sh -e ed -i

* Print the usage:

        ./CLItxties -h

## OK, but how can I access my content?

Suppose that `MyCoolPost` is your customized URL. You'll find your post at
`http://txti.es/MyCoolPost` and the edit link would be `http://txti.es/MyCoolPost/edit`.

## Dependencies

* `curl`
* `lynx`
* `nano` (unless you change it to some other editor in the source code or with `-e`)
