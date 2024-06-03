close all
[fname, path] = uigetfile('*.*', '选择图像文件');
fname = strcat(path, fname);

% 读取图像
image = imread(fname);

% 转换为灰度图像
gray = rgb2gray(image);

% 应用高斯模糊去噪
blurred = imgaussfilt(gray, 2);

% 创建结构元素
se = strel('rectangle', [15, 15]);

% 顶帽变换
top_hat = imtophat(blurred, se);

% 底帽变换
black_hat = imbothat(blurred, se);

% 合并变换结果
shadow_removed = imadd(blurred, top_hat);
shadow_removed = imsubtract(shadow_removed, black_hat);

% 自适应阈值二值化
binary = imbinarize(shadow_removed, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.4);

% 创建结构元素
se = strel('rectangle', [3, 3]);

% 先膨胀后腐蚀（开运算）消除噪声
opened = imopen(binary, se);

imshow(opened)

% 使用Canny边缘检测
edges = edge(opened, 'canny');
imshow(edges)
% 使用霍夫变换检测直线
[H, T, R] = hough(edges);
P = houghpeaks(H, 5, 'threshold', ceil(0.3 * max(H(:))));
lines = houghlines(edges, T, R, P, 'FillGap', 5, 'MinLength', 7);

% 找到最长的直线
max_len = 0;
best_line = [];
for k = 1:length(lines)
    % 计算直线的长度
    len = norm(lines(k).point1 - lines(k).point2);
    if len > max_len
        max_len = len;
        best_line = lines(k);
    end
end

% 使用最长直线的端点计算倾斜角度
point1 = best_line.point1;
point2 = best_line.point2;
delta_y = point2(2) - point1(2);
delta_x = point2(1) - point1(1);
angle = atan2(delta_y, delta_x) * 180 / pi;  % 将角度转换为度

% 显示原始图像并绘制最长直线
figure, imshow(opened), title('Detected Longest Line');
hold on
xy = [best_line.point1; best_line.point2];
plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');

% 绘制起点和终点
plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red');
hold off

% 旋转矫正图像
corrected_image = imrotate(opened, angle, 'bicubic', 'crop');

% 显示矫正后的图像
figure, imshow(corrected_image), title('Corrected Image');


% c = ~corrected_image;
% % 测量数字的区域
% se = strel('square', 7);
% im_close = imclose(c, se);
% imshow(im_close);
% s = regionprops(im_close, 'BoundingBox');
% 
% % 在数字周围创建框
% bb = round(reshape([s.BoundingBox], 4, []).');
% % 显示原始图像
% figure;
% imshow(corrected_image);
% hold on;
% 
% % 绘制数字的外接矩形框
% for idx = 1:numel(s)
%     rectangle('Position', [s(idx).BoundingBox(1), s(idx).BoundingBox(2), ...
%         s(idx).BoundingBox(3), s(idx).BoundingBox(4)], ...
%         'EdgeColor', 'r', 'LineWidth', 2);
% end
% 
% hold off;

% 连通组件标记
corrected_image =~corrected_image;
[labelled_image, num_labels] = bwlabel(corrected_image);

% 获取每个连通区域的属性
props = regionprops(labelled_image, 'Area');

% 设置一个阈值，过滤掉过大的连通区域
threshold_area = 3000; % 根据实际情况调整阈值
threshold_area2 = 100;
% 标记过大的连通区域
large_areas = [props.Area] > threshold_area;
small_areas = [props.Area] < threshold_area2;
% 将过大的连通区域标记为背景
for i = 1:num_labels
    if large_areas(i)||small_areas(i)
    
        labelled_image(labelled_image == i) = 0;
    end
end
imshow(labelled_image);
% 重新进行连通组件标记
[labelled_image, num_labels] = bwlabel(labelled_image);

% 获取新的连通区域的属性
new_props = regionprops(labelled_image, 'BoundingBox');

% 绘制新的数字外接矩形框
figure;
imshow(corrected_image);
hold on;
for idx = 1:numel(new_props)
    rectangle('Position', new_props(idx).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
end
hold off;
