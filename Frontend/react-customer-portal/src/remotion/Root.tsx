import { Composition } from 'remotion';
import { PlatformExplainerVideo } from '../components/video/PlatformExplainerVideo';

export const RemotionRoot = () => {
  return (
    <Composition
      id="PlatformExplainer"
      component={PlatformExplainerVideo}
      durationInFrames={600}
      fps={30}
      width={1920}
      height={1080}
    />
  );
};

