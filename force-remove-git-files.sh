# Use this to force removal of all history of a given file.
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch FILE_NAME' \
  --prune-empty --tag-name-filter cat -- --all

# After, run this:
# git push origin --force --all