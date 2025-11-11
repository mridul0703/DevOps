#!/bin/bash
echo "💣 Destroying all Azure resources..."
terraform destroy -auto-approve
echo "✅ All resources destroyed successfully."
