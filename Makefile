NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= todd

MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

NIXNAME ?= vm-aarch64

SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# We need to do some OS switching below.
UNAME := $(shell uname)

switch:
ifeq ($(UNAME), Darwin)
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
endif

vm/bootstrap0:
	ssh $(SSH_OPTIONS) -p $(NIXPORT) root@$(NIXADDR) "\
		parted /dev/nvme0n1 -- mklabel gpt; \
		parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/nvme0n1 -- mkpart primary linux-swap -8GB 100%; \
		parted /dev/nvme0n1 -- mkpart primary 512MB -8GB; \
		parted /dev/nvme0n1 -- set 1 esp on; \
		sleep 1; \
		mkfs.fat -F 32 -n boot /dev/nvme0n1p1; \
		mkswap -L swap /dev/nvme0n1p2; \
		mkfs.btrfs -L nixos /dev/nvme0n1p3; \
		mount -t btrfs -o compress=zstd /dev/nvme0n1p3 /mnt; \
		btrfs subvolume create /mnt/@; \
		btrfs subvolume create /mnt/@home; \
		btrfs subvolume create /mnt/@nix; \
		umount /mnt; \
		sleep 1; \
		mount -t btrfs -o compress=zstd,subvol=/@ /dev/nvme0n1p3 /mnt; \
		mkdir -p /mnt/{home,nix,boot}; \
		mount -t btrfs -o compress=zstd,subvol=/@home /dev/nvme0n1p3 /mnt/home; \
		mount -t btrfs -o compress=zstd,noatime,subvol=/@nix /dev/nvme0n1p3 /mnt/nix; \
		mount /dev/nvme0n1p1 /mnt/boot; \
		swapon /dev/nvme0n1p2; \
		mv /mnt/etc/nixos /mnt/etc/nixos.bak; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\\.stateVersion = .*/a \
			nix = {\n \
				package = pkgs.nixVersions.git;\n \
				extraOptions = \"experimental-features = nix-command flakes\";\n \
				settings = {\n \
					use-xdg-base-directories = true;\n \
				};\n \
			};\n \
			time.timeZone = \"Asia/Singapore\";\n \
			services.openssh.enable = true;\n \
			services.openssh.settings = {\n \
				PasswordAuthentication = true;\n \
				PermitRootLogin = \"yes\";\n \
			};\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix"; \
		nixos-install --no-root-passwd && reboot; \

vm/bootstrap:
	NIXUSER=root $(MAKE) vm/copy
	NIXUSER=root $(MAKE) vm/switch
	$(MAKE) vm/secrets
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo reboot; \
	"

vm/secrets:
	# GPG keyring
	sudo rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='.#*' \
		--exclude='S.*' \
		--exclude='*.conf' \
		$(HOME)/.gnupg/ $(NIXUSER)@$(NIXADDR):~/.gnupg
	# SSH keys
	sudo rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh

vm/copy:
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='vendor/' \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--exclude='iso/' \
		--rsync-path="sudo rsync" \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-config

vm/switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo nixos-rebuild switch --flake \"/nix-config#${NIXNAME}\" \
	"
