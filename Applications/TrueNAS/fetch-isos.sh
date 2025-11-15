#!/bin/bash

# Function: list_truenas_isos
# Description: Fetches the content of the TrueNAS download page and lists only 
#              the latest patched stable ISO URL for each major release (YY.MM) 
#              from the current year and the previous year.
list_truenas_isos() {
    local BASE_URL="https://download.truenas.com"
    local URL="$BASE_URL"
    
    # Dynamically determine the current year and last year (two-digit format, e.g., 25, 24)
    local current_year_short=$(date +%y)
    local last_year_short=$(date -d "1 year ago" +%y)
    
    # Create a regex pattern to match versions starting with YY. (e.g., 25. or 24.)
    # The dot (.) is escaped to match the literal character.
    local year_pattern="${current_year_short}\.|${last_year_short}\."
    
    # Declare associative array to store the highest version found for each major release (YY.MM)
    # Format: [YY.MM]="path/to/highest_version.iso"
    declare -A latest_isos

    echo "Fetching all stable ISO links for releases from years $last_year_short and $current_year_short..."
    echo "------------------------------------------------------------------"

    # 1. Fetch, filter for ISO links, clean up paths, and filter by year and stability
    local filtered_paths=$(curl -sL "$URL" | \
        grep -oE 'href="[^"]+\.iso"' | \
        sed 's/href="//; s/"$//' | \
        # EXCLUDING nightly, ALPHA, BETA, and RC releases
        grep -vE '(nightly|ALPHA|BETA|RC)' | \
        # Filtering for current year and last year releases (e.g., 25.XX or 24.XX)
        grep -E "$year_pattern"
    )
    
    if [ -z "$filtered_paths" ]; then
        echo "Error: No stable ISOs found for releases from years $last_year_short and $current_year_short."
        return 1
    fi

    # 2. Process all found paths to find the highest patch version for each major release (YY.MM)
    while read -r path; do
        # Extract the filename (e.g., TrueNAS-SCALE-25.04.2.6.iso)
        local filename=$(basename "$path")
        
        # Extract the full version number (e.g., 25.04.2.6) from the filename
        # This is more robust than extracting from the path components.
        local version=$(echo "$filename" | sed -E 's/.*TrueNAS-SCALE-([0-9]{2}\.[0-9]{2}(\.[0-9]+)*)\.iso.*/\1/')
        
        # Extract the major version (YY.MM)
        local major_version=$(echo "$version" | cut -d'.' -f1,2)

        # Check if version extraction was successful and it's a valid major version
        if [[ -n "$major_version" && "$version" =~ ^[0-9]{2}\.[0-9]{2} ]]; then

            # Get the currently stored path and version for this major release
            local current_path=${latest_isos["$major_version"]}
            
            if [ -z "$current_path" ]; then
                # No version stored yet for this major release, so store the current one
                latest_isos["$major_version"]="$path"
            else
                # Extract the stored version for comparison
                local current_version=$(basename "$current_path" | sed -E 's/.*TrueNAS-SCALE-([0-9]{2}\.[0-9]{2}(\.[0-9]+)*)\.iso.*/\1/')
                
                # Compare versions numerically (V is for version number comparison)
                # If the current version is greater than the stored version, update
                # The printf/sort trick reliably handles version number comparison (e.g., 25.04.2.6 > 25.04.0)
                if printf '%s\n' "$version" "$current_version" | sort -V | tail -n 1 | grep -q "$version"; then
                    latest_isos["$major_version"]="$path"
                fi
            fi
        fi
    done <<< "$filtered_paths"

    # 3. Output the final list of the latest patched ISOs for each major version
    echo "Found the latest patched stable ISOs for each major release (YY.MM) from $last_year_short and $current_year_short:"

    # Output the results, sorted by major version
    local sorted_versions=$(
        for key in "${!latest_isos[@]}"; do
            echo "$key"
        done | sort -V
    )

    while read -r major_version; do
        local path=${latest_isos["$major_version"]}
        # Correctly reconstruct the full absolute URL
        local full_url="$BASE_URL/$path"
        echo "$full_url"
    done <<< "$sorted_versions"
    
    echo "------------------------------------------------------------------"
    echo "Done."
}

# --- Script Execution ---

# Check if curl is installed
if ! command -v curl &> /dev/null
then
    echo "Error: 'curl' command not found. Please install it to run this function." >&2
    exit 1
fi

# Call the function to display the list of ISOs
list_truenas_isos