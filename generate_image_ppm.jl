image_w = 256
image_h = 256

touch("image.ppm")
im = open("image.ppm", "w")

write(im, "P3\n$image_w $image_h\n255\n")

for j in image_h:-1:1
    for i in 1:image_w
        r = i / (image_w)
        g = j / (image_h)
        b = 0.25

        ir = trunc(255.999 * r)
        ig = trunc(255.999 * g)
        ib = trunc(255.999 * b)

        write(im, "$ir $ig $ib\n")
    end
end

close(im)