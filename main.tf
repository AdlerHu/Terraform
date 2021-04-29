terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.65.0"
    }
  }
}

provider "google" {
  credentials = file(var.credential_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

# allow-http
resource "google_compute_firewall" "http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  priority = 1000
  source_tags = ["http"]
}

# allow-https
resource "google_compute_firewall" "https" {
  name    = "allow-https"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  priority = 1000
  source_tags = ["https"]
}

# allow-rdp
resource "google_compute_firewall" "rdp" {
  name    = "allow-rdp"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
  priority = 1000
  source_tags = ["rdp"]
}

# allow-internal
resource "google_compute_firewall" "internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }
    
  source_ranges = ["10.128.0.0/9"]
  priority = 1000
  source_tags = ["internal"]
}

# allow-ping
resource "google_compute_firewall" "ping" {
  name    = "allow-ping"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  priority = 1000
  source_tags = ["ping"]
}

# allow-ssh
resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  priority = 1000
  source_tags = ["ssh"]
}

# create VM instance
resource "google_compute_instance" "instance0" {
  name         = "instance0"
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["ssh", "http", "https", "ping"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  
  metadata_startup_script = "mkdir /tmp/adler/"
  
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

# create another VM instance
resource "google_compute_instance" "instance1" {
  name         = "instance1"
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["ssh", "http", "https", "ping"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-pro-cloud/ubuntu-pro-2004-lts"
    }
  }
  
  metadata_startup_script = "mkdir /tmp/adler/"
  
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}
