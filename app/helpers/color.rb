module Color
    def self.hex(h)
        h = h.delete("#")
        rgb = [h[0, 2], h[2, 2], h[4, 2]].map { |c| c.to_i(16) }
        rgb << h[6, 2].to_i(16) if h.length == 8   # optional alpha: "#14141eff"
        rgb
    end
end