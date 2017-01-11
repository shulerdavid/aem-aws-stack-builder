create-aem:
	./scripts/create-aem-stacks.sh

delete-aem:
	./scripts/delete-aem-stacks.sh

clean:
	rm -rf logs
	rm -f *.cert *.key
	rm -f ansible/playbooks/apps/*.retry

deps:
	pip install -r requirements.txt

lint:
	./scripts/lint.sh

create-shared-stack:
	./scripts/create-stack.sh aem-${stack}-stack cloudformation/network/${stack}.yaml

delete-shared-stack:
	./scripts/delete-stack.sh aem-${stack}-stack cloudformation/network/${stack}.yaml


create-shared-roles-stack:
	./scripts/create-stack.sh aem-roles-stack cloudformation/apps/roles.yaml

delete-shared-roles-stack:
	./scripts/delete-stack.sh aem-roles-stack cloudformation/apps/roles.yaml


create-stack:
	./scripts/create-stack.sh ${prefix}-aem-${stack}-stack cloudformation/apps/${stack}.yaml

delete-stack:
	./scripts/delete-stack.sh ${prefix}-aem-${stack}-stack cloudformation/apps/${stack}.yaml

ansible-create-stack:
	ansible-playbook -vvv ansible/${stack}.yaml -i ansible/${inventory} --tags create

ansible-delete-stack:
	ansible-playbook -vvv ansible/${stack}.yaml -i ansible/${inventory} --tags delete


# convenient targets for creating certificate using OpenSSL, upload to and remove from AWS IAM
CERT_NAME = "aem-stack-certificate"

create-cert:
	openssl req \
	    -new \
	    -newkey rsa:4096 \
	    -days 365 \
	    -nodes \
	    -x509 \
	    -subj "/C=AU/ST=Victoria/L=Melbourne/O=Sample Organisation/CN=$(CERT_NAME)" \
	    -keyout $(CERT_NAME).key \
	    -out $(CERT_NAME).cert

upload-cert:
	aws iam upload-server-certificate \
	    --server-certificate-name $(CERT_NAME) \
	    --certificate-body "file://$(CERT_NAME).cert" \
	    --private-key "file://$(CERT_NAME).key"

delete-cert:
	aws iam delete-server-certificate \
	    --server-certificate-name $(CERT_NAME)

.PHONY: create-aem delete-aem clean deps lint create-cert upload-cert delete-cert
