# bureaucracy-guidebook
The guidebook for Bureaucracy: <https://processempathy.github.io/>


This book is not "7 types of Bureaucrats You'll Encounter" or even "5 Tips on how to be a Better Bureaucrat."

I'm not able to consolidate the content down to a standard (concise) essay format, e.g., <https://www.bucks.edu/media/bcccmedialibrary/pdf/FiveParagraphEssayOutlineJuly08_000.pdf>


I assume the distribution format is PDF, or something else that supports hyperlinks. 


Blog posts:
* <https://allen-faulton.medium.com/the-fine-art-of-navigating-bureaucracy-a91236a29e58>i

# To build PDF/HTML/EPUB from .tex

```bash
make docker_build
./make.sh all
```
The .tex files are stored on Overleaf. 
```bash
make rm
make uz
./make.sh all
```


# Readability scoring

* <https://pypi.org/project/py-readability-metrics/>
