#!/usr/bin/env bash
# Aplica políticas de contribuição nos repos Repost (somente colaboradores).
# Requer: gh autenticado com escopo repo.
set -euo pipefail

OWNER="${GITHUB_OWNER:-devrenatafraga}"
REPOS=(
  repost-documentation
  repost-manager-backend
  repost-manager-frontend
  repost-frontend
)

apply_policy() {
  local repo="$1"
  local repo_id
  repo_id=$(gh api graphql -f query="
    query {
      repository(owner: \"$OWNER\", name: \"$repo\") { id }
    }" --jq .data.repository.id)

  gh api graphql --input - <<EOF
{
  "query": "mutation(\$input: UpdateRepositoryInput!) { updateRepository(input: \$input) { repository { name pullRequestCreationPolicy issueCreationPolicy } } }",
  "variables": {
    "input": {
      "repositoryId": "$repo_id",
      "pullRequestCreationPolicy": "COLLABORATORS_ONLY",
      "issueCreationPolicy": "COLLABORATORS_ONLY"
    }
  }
}
EOF

  echo "OK $OWNER/$repo"
}

for repo in "${REPOS[@]}"; do
  apply_policy "$repo"
done

echo "Políticas aplicadas: PR e issues restritos a colaboradores."
