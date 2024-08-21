#/bin/bash

package_name=$1
package_version=$2
package_directory=${package_name}-${package_version}

EXIT_CODE=0

echo Creating lock file for ${package_name} version ${package_version}

# A safe place to do our work.
temp_dir=$(mktemp -d)
pushd .
cd ${temp_dir}
http_status=$(curl -o crate.tar.gz -w "%{http_code}" -L "https://crates.io/api/v1/crates/${package_name}/${package_version}/download")

if [ "${http_status}" -ne 200 ]; then
  echo HTTP Status: ${http_status}
  echo "This is a failure"
  popd
  EXIT_CODE=1
else
  tar -xzf crate.tar.gz
  cd ${package_directory}
  cargo update
  popd

  cp ${temp_dir}/${package_directory}/Cargo.lock ${package_name}.lock
  echo Output: ${package_name}.lock
fi

# Clean up after yourself.
rm -rf ${temp_dir}

exit ${EXIT_CODE}
