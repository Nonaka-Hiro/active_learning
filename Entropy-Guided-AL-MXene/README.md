# Data-Efficient Construction of MXene Interatomic Potentials via Entropy-Guided Active Learning

This repository contains the datasets, pretrained models, and source codes associated with the following manuscript:

H. Nonaka, Y. Nagao, W. Jia, J. Hirotani, and L. Liu,
"Data-Efficient Construction of MXene Interatomic Potentials via Entropy-Guided Active Learning",
submitted to Computational Materials Science (2026).

## Repository structure

```
.
├── data/
│   ├── DFT_dataset/            Original DFT training data
│   │   ├── DFT_dataset_Ti2C/   Ti₂C dataset
│   │   └── DFT_dataset_Ti3C2/  Ti₃C₂ dataset
│   ├── AL_iteration0/          Active learning iteration 0 (initial data)
│   ├── AL_iteration1/          Active learning iteration 1
│   ├── AL_iteration2/          Active learning iteration 2
│   ├── AL_iteration3/          Active learning iteration 3
│   └── AL_iteration4/          Active learning iteration 4 (final)
├── models/
│   ├── Ti2C/
│   │   ├── frozen_model.pb     Pretrained MLIP for Ti₂C MXene
│   │   └── input.json          DeePMD-kit training configuration
│   └── Ti-C/
│       ├── frozen_model.pb     Pretrained MLIP for Ti-C MXene
│       └── input.json          DeePMD-kit training configuration
├── code/
│   ├── active_learning.sh      Bash script for active learning workflow
│   └── entropy_analysis.sh              Bash script for entropy-based structure selection
├── figures/
│   └── Figure_1.png ~ Figure_12.png  Figures used in the manuscript
├── LICENSE
└── README.md
```

## Data format
All DFT data are stored in DeePMD-kit raw format:

| File | Description |
|------|-------------|
| `box.raw` | Simulation cell vectors (Å) |
| `coord.raw` | Atomic coordinates (Å) |
| `energy.raw` | Total energies (eV) |
| `force.raw` | Atomic forces (eV/Å) |
| `type.raw` | Atom type indices |
| `type_map.raw` | Element symbols |

## Pretrained models

Pretrained DeePMD-kit models are provided in the `models/` directory.

| System | File | Description |
|--------|------|-------------|
| Ti₂C   | `models/Ti2C/frozen_model.pb`  | Final MLIP for Ti₂C MXene  |
| Ti-C  | `models/Ti-C/frozen_model.pb` | Final MLIP for Ti-C MXene |

To evaluate the model on a test dataset:

```bash
dp test -m models/Ti-C/frozen_model.pb \
        -s data/DFT_dataset/DFT_dataset_Ti3C2/1_dpdata/<structure_dir>
```

## Computational environment

- Python 3.8.20
- Required packages:
  - numpy
  - pandas
  - matplotlib
  - scikit-learn
  - deepmd-kit (version 2.x)

## Usage

1. Prepare DFT datasets (see `data/DFT_dataset/`).
2. Train initial DeePMD models using `data/AL_iteration0/` and the configuration in `models/Ti-C/input.json`.
3. Run entropy-guided active learning using `code/active_learning.sh`.
4. Select structures based on differential entropy using `code/entropy_analysis.sh`.
5. Repeat steps 2–4 for each AL iteration (1–4).

## License

This dataset is licensed under the Creative Commons Attribution 4.0 International License (CC BY 4.0).
See the [LICENSE](LICENSE) file for details.

## Citation

If you use this dataset or code in your research, please cite:

```
H. Nonaka, Y. Nagao, W. Jia, J. Hirotani, and L. Liu,
"Data-Efficient Construction of MXene Interatomic Potentials via Entropy-Guided Active Learning",
Computational Materials Science (2026).
```

## Contact

Lijun Liu  
The University of Osaka  
Email: liu@mech.eng.osaka-u.ac.jp
