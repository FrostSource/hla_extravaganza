# Templates

> ### A set of template files for the different types of assets, to be used if you want to submit additions. Files marked with * are required to keep consistency between different authors.

---

## Prefabs

- `*` README.md
        
    An overview of the prefab and all properties and I/O.

- example_template.vmap

    A map based on `basic_setup.vmap` with a smaller area and added light to illuminate all walls even when the preview lighting hasn't been compiled. Example maps are used to showcase the prefab in practice.

> The README.md **must** contain a list of required assets if you want your prefab added to the release zip. The `pack_releases.py` script uses this list to compile the assets into the zip file.