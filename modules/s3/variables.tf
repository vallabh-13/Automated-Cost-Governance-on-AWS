variable "project_name" {
  description = "Short name used for tagging and resource prefixes."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to S3 resources."
  type        = map(string)
  default     = {}
}

variable "governance_tag_value" {
  description = "Tag value used to scope cleanup actions (e.g., CostGovernance=true)."
  type        = string
  default     = "true"
}

# MIME type mapping for frontend files
variable "mime_types" {
  description = "Mapping of file extensions to MIME types for S3 hosting."
  type        = map(string)
  default = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".json" = "application/json"
  }
}
