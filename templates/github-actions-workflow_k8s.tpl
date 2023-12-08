  
  
  ${prefix}k8s:
    name: Deploy_${prefix}k8s
    runs-on: ubuntu-latest
    needs: kubescape
    steps:
    - uses: actions/checkout@v4
    - uses: actions-hub/kubectl@master
      env:
        KUBE_TOKEN: $${{ secrets.${prefix}KUBE_TOKEN }}
        KUBE_HOST: $${{ secrets.${prefix}KUBE_HOST }}
        KUBE_CERTIFICATE: $${{ secrets.${prefix}KUBE_CERTIFICATE }}
      with:
        # First deployment
        args: apply -f manifest/*.yaml