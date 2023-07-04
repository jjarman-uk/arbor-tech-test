locals {
  name   = format("%s-%s", var.environment, replace(basename(path.cwd), "_", "-"))
  region = "us-east-1"

  tags = {
    Name       = format("%s-%s", var.environment, "arbor-tech-test")
    GithubRepo = "arbor-tech-test"
  }
}

