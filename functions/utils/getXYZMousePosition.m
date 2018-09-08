function cpFront = getXYZMousePosition(hi)

camPosition = get(hi,'CameraPosition');
% Get currentPoint in figure and axes
fp = get(gcf,'CurrentPoint');
set(hi,'Units',get(gcf,'Units'));
ap = get(hi,'Position');
cp = get(hi,'CurrentPoint');
% Only when cursor is into axes location
if ~(fp(1) >= ap(1) && fp(1) <= ap(1)+ap(3) && fp(2) >= ap(2) && fp(2) <= ap(2)+ap(4)); cpFront=[]; return; end
cpBack = cp(1,:);
cpFront = cp(2,:);
sBack = norm(camPosition-cpBack);
sFront = norm(camPosition-cpFront);
if sBack < sFront
    cpFront = cp(1,:); %cpBack = cp(2,:);
end
