#!/bin/bash
  clear
  # Get the scanner details, scanimage -L lists the scanners connected, and then we get the device from this
  device="epson2:libusb:001:007"

  # Prompt the user for single or timelapse scanning, and a couple of options
  echo "Select scanning option:"
  echo "----------------------------------"
  OPTIONS="Single Timelapse Exit"
  select opt in $OPTIONS; do

    if [ "$opt" = "Single" ]; then
      echo "Type file name and hit [ENTER] (**WARNING: Will overwrite any existing file of same name):"
      read fname
      extension=".tiff"
      echo "Select scanning brightness:"
      filename="$fname$extension"
	OPTIONS2="Normal Darker Back"
	select opt2 in $OPTIONS2; do
	  if [ "$opt2" = "Normal" ]; then
      # Run the single imaging for normal brightness
	    sudo scanimage -d $device --resolution 600 --format tiff --mode color --source 'TPU8x10' --focus-position 'Focus 2.5mm above glass' > $filename
            echo "Scanning"
            echo "Scan complete!"
            echo "Image saved as $filename"
            echo "<Press any key to continue>"
            read -n 1 -s
            clear
            break
    # Run the single imaging for darker images
	  elif [ "$opt2" = "Darker" ]; then
            sudo scanimage -d $device --resolution 600 --format tiff --mode color --source 'TPU8x10' --focus-position 'Focus 2.5mm above glass' --brightness -3 > $filename
            echo "Scanning"
            echo "Scan complete!"
            echo "Image saved as $filename"
            echo "<Press any key to continue>"
            read -n 1 -s
            clear
            break
          elif [ "$opt2" = "Back" ]; then
	    clear
            break
          else
            echo "Selection not supported"
            echo "<Press any key to return to menu>"
            read -n 1 -s
            clear
            clear
            echo "Select scanning brightness:"
            echo "1) Normal"
            echo "2) Darker"
            echo "3) Back"
            continue
          fi
        done
      clear
      echo "Select scanning option:"
      echo "----------------------------------"
      echo "1) Single"
      echo "2) Timelapse"
      echo "3) Exit"
    elif [ "$opt" = "Timelapse" ]; then
      clear
      # Prompt the user for some parameters for the timelapse
      echo "Timelapse plate scanning"
      echo "----------------------------------"
      echo "Enter total time period (hours):"
      read timeperiod
      echo "Enter number of scans per hour:"
      read scans
      # Calculate approximate disk space, time elapsed, etc
      MBdiskspace=$((scans*timeperiod*65))
      GBdiskspace=$((MBdiskspace/1000))
      scanmin=$((60/scans))
      totalscans=$((scans*timeperiod))
      echo "Type base file name and hit [ENTER] (**WARNING: Will overwrite any existing file of same name):"
      echo "      (Note: Files will be appended with integers indicating which scan number they correspond to)"
      read fname
      extension=".tiff"
      
      echo "Preparing experiment..."
      echo "<Press any key to continue>"
      read -n 1 -s
      clear
      echo "Timelapse plate scanning"
      echo "----------------------------------"
      echo "Set to image $scans times per hour over $timeperiod hours"
      echo "This will take up about $MBdiskspace Mb of disk space ($GBdiskspace Gb)"
      echo "<Type yes to proceed, or anything else to return to menu>"
      read yn
      sleeptime=$((scanmin*60))
      if [ "$yn" = "yes" ]; then
        # Start experiment at this point.  Need a progress bar, time elapsed, time remaining, # images taken
        # Time elapsed
        telapsed=0
        # Time remaining
        tremain=$((timeperiod*60))
        # Number of scans
        scanscounter=0
	# Filename with time of scan appended
  filenametime="$fname$scanscounter$extension"
	# The call to the actual scanimage function for the 0 time
  sudo scanimage -d $device --resolution 600 --format tiff --mode color --source 'TPU8x10' --focus-position 'Focus 2.5mm above glass' --brightness -3 > $filenametime
        # We repeat this until the time remaining is 0
        until [ $tremain -le 0 ]; do
          filenametime="$fname$scanscounter$extension"
          percent=$((scanscounter*100/totalscans))
          telapsed=$((scanmin*scanscounter))
          tremain=$(((timeperiod*60)-telapsed))         
          scanscounter=$((scanscounter+1)) 
          echo "($percent% complete) $telapsed minutes elapsed, $tremain minutes remaining"
          # The call to the actual scanimage function for the other time points
          sudo scanimage -d $device --resolution 600 --format tiff --mode color --source 'TPU8x10' --focus-position 'Focus 2.5mm above glass' --brightness -3 > $filenametime
          # Wait the amount of time between scans
          sleep $sleeptime
        done
        clear
        echo "Experiment completed in $timeperiod hours"         
        exit      
      else
        clear
        echo "Select scanning option:"
        echo "----------------------------------"
        echo "1) Single"
        echo "2) Timelapse"
        echo "3) Exit"
        continue
      fi
    elif [ "$opt" = "Exit" ]; then
      exit
    else
      clear
      echo "Select scanning option:"
      echo "----------------------------------"

    fi
done
