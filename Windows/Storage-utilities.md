# Use of Storage utilities in Windows

## chkdsk

Checks the file system and file system metadata of a volume for logical and physical errors. If used without parameters, chkdsk displays only the status of the volume and does not fix any errors. If used with the /f, /r, /x, or /b parameters, it fixes errors on the volume.

Official docs: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/chkdsk

### Parameters

| Parameter | Description |
| --- | --- |
| `<volume>` | Specifies the drive letter (followed by a colon), mount point, or volume name. |
| /f | Fixes errors on the disk. The disk must be locked. If chkdsk cannot lock the drive, a message appears that asks you if you want to check the drive the next time you restart the computer. |
| /r | Locates bad sectors and recovers readable information. The disk must be locked. /r includes the functionality of /f, with the additional analysis of physical disk errors. |
| /b | Use with NTFS only. Clears the list of bad clusters on the volume and rescans all allocated and free clusters for errors. /b includes the functionality of /r. Use this parameter after imaging a volume to a new hard disk drive. |

### Example

```bash
chkdsk d: /f
```

## Clear-Disk

Cleans a disk by removing all partition information and un-initializing it, erasing all data on the disk.

Official docs: https://learn.microsoft.com/en-us/powershell/module/storage/clear-disk

### Parameters

| Parameter | Description |
| --- | --- |
| -Number | Specifies the disk number of the disk on which to perform the clear operation. For a list of available disks, see the Get-Disk cmdlet. |
| -RemoveData | Enables the removal of all of the data on the disk. |
| -RemoveOEM | Enables the removal of any OEM recovery partitions from the disk. |

### Example

This example clears the disk regardless of whether it contains data or OEM partitions.

```bash
Clear-Disk -Number 5 -RemoveData -RemoveOEM
```

## Format-Volume

The Format-Volume cmdlet formats one or more existing volumes, or a new volume on an existing partition. This cmdlet returns the object representing the volume that was just formatted, with all properties updated to reflect the format operation.

To create a new volume, use this cmdlet in conjunction with the Initialize-Disk and New-Partition cmdlets.

Official docs: https://learn.microsoft.com/en-us/powershell/module/storage/format-volume

### Parameters

| Parameter | Description |
| --- | --- |
| -AllocationUnitSize | Specifies the allocation unit size to use when formatting the volume. |
| -DriveLetter | Specifies the drive letter of the volume to format. |
| -FileSystem | Specifies the file system with which to format the volume. The acceptable values for this parameter are:NTFS, ReFS, exFAT, FAT32, and FAT. |
| -Force | Specifies the override switch. |
| -Full | Performs a full format. A full format writes to every sector of the disk, takes much longer to perform than the default (quick) format, and is not recommended on storage that is thinly provisioned. |
| -NewFileSystemLabel | Specifies a new label to use for the volume. |


### Example

This example performs a full format of the E volume using the NTFS file system and allocation size 8192.

```bash
Format-Volume -DriveLetter D -FileSystem NTFS -AllocationUnitSize 8192 -Full -Force
```