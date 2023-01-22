function cell = dataloader_pichone()
p = dir('pichone');
N = numel(p);
cell = {'data','Fs'};
index = 2;

for i = 3:numel(p)
    temp_dir = "pichone\"+p(i).name;
    temp_obj = dir(temp_dir+"\*.wav");
    Nf = numel(temp_obj);
    for j = 1:Nf
        name_temp = temp_obj(j).name;
        [y_temp  Fs_temp] = audioread(temp_dir+"\"+name_temp);
                                               
        cell(index,:) = {y_temp, Fs_temp};
        index = index+1;
   end
end

end