docker run -d \
    -it \
    --name dain-app \
    --mount type=bind,source="$(pwd)"/src,target=/DAIN-App \
    python my_design.py 
