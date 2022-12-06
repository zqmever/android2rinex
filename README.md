# android2rinex
Android GNSS raw measurements to RINEX observations

## Requirements
- MATLAB R2020a (but it should also work with R2016b or later)

## Structure
- `+android` reads Android GNSS raw observation file
    - `+formatSpec` stores the format of the input/output fields, specified using formatting operators
- `+rinex` converts Android GNSS raw data to RINEX data
- `tests` stores test files for testing

## Demonstration
Please see `demo.m` for details.  

## Usage & Syntax
### New an Android GNSS dataset
```python
android_dataset = android.DataSet()
```
- Inputs:
    - None

- Outputs:
    - `android_dataset` Android GNSS raw observation dataset

### Read Android GNSS dataset
```python
android_dataset = android.readRawFile(raw_file, [android_dataset])
```
- Inputs:
    - `raw_file` Android GNSS raw observation data file, usually in `.txt` format
    - `android_dataset` [optional] Android GNSS raw observation dataset

- Outputs:
    - `android_dataset` Android GNSS raw observation dataset

### New an RINEX dataset
```python
rinex_dataset = rinex.newRinexDataSet([rinex_version])
```
- Inputs:
    - `rinex_version` [optional] RINEX format version

- Outputs:
    - `rinex_dataset` RINEX dataset

### Convert the Android GNSS dataset to the RINEX dataset
```python
rinex_dataset = rinex.convertAndroidToRinex(android_dataset, [rinex_dataset])
```
- Inputs:
    - `android_dataset` Android GNSS raw observation dataset
    - `rinex_dataset` [optional] RINEX dataset

- Outputs:
    - `rinex_dataset` RINEX dataset

