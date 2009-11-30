class SubSelectDict(dict):
    
    def subset(self, *keys):
        subset = SubSelectDict()
        for key in keys:
            if self.has_key(key):
                subset[key] = self[key]
        return subset
